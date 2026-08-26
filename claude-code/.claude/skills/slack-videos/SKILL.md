---
name: slack-videos
description: List the videos Gerrard has posted to the pod-c-internal Slack channel, newest first, with the text of the message each video was attached to so he can tell what it demonstrates. Read-only — never posts anything. Use when the user says "slack videos", "/slack-videos", "what videos have I posted", "list my videos in slack", "find my screen recordings in slack", "my slack recordings", or otherwise asks for videos he shared in Slack.
allowed-tools: Read, Write, mcp__claude_ai_Slack__slack_search_public_and_private, mcp__claude_ai_Slack__slack_read_channel, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_search_channels, mcp__claude_ai_Slack__slack_search_users
---

List every video **Gerrard** attached to a message in a Slack channel, newest first, alongside the message text that accompanied it. Strictly read-only: never send a message, add a reaction, or modify anything in Slack. (It does write the local ID cache described in step 0.)

## Fixed context

- **Author:** always Gerrard. This skill never lists anyone else's videos.
- **Channel:** `#pod-c-internal` by default. If the invocation names a different channel (e.g. "in #pod-c-code-reviews"), use that one instead.
- **Date range:** all history by default. If the invocation names a range ("since June", "last month", "in 2026"), translate it into `after:YYYY-MM-DD` / `before:YYYY-MM-DD` modifiers and append them to both searches below.

## 0. Resolve Slack IDs (cached)

Slack channel and user IDs are not stored in this repo — resolve them at runtime and cache them.

**Cache file:** `${TMPDIR:-/tmp}/claude-pod-c-ids.json`, shaped:

```json
{
  "self_user_id": "<Slack user ID>",
  "channels": {
    "pod-c-internal": "<channel ID>"
  }
}
```

Read the cache with `Read`. A missing file, unparseable JSON, or a missing/empty key is **not an error** — it just means that value has to be resolved. Never fail the skill because of the cache. Leave any cached keys this skill doesn't need exactly as they are; other skills share this file.

Resolve whatever is missing:

- **Channel ID** — `slack_search_channels` with the channel name as the query and `channel_types="public_channel,private_channel"` (pod-c channels are private); take the ID of the exact name match.
- **Gerrard's own Slack user ID** — get his identity from local machine config rather than hardcoding it: run `git config --global user.name` (fall back to `git config --global user.email` if the name is empty), then pass that value as the query to `slack_search_users` and take the single matching user's ID. If neither config value resolves to exactly one user, ask him which account is his rather than guessing.

After resolving, rewrite the whole cache file with `Write` so all known values are persisted for next time. Below, **`<CH>`** is the resolved channel ID and **`<ME>`** is Gerrard's resolved Slack user ID.

## 1. Video pass — find the files

File search is the authoritative list of videos; it is the only search that reliably distinguishes a video from any other attachment.

Call `slack_search_public_and_private` with:

- `query`: `in:<#CH> from:<@ME> type:videos`
- `content_types`: `files`
- `sort`: `timestamp`, `sort_dir`: `desc`
- `include_context`: `false`

Results are capped at 20 per page — **always follow `next_cursor` until pagination reports no more pages**, or the list will silently be truncated.

For each file record keep: title/filename, file type, size, created timestamp, file ID, permalink.

Note that `type:videos` covers `.mov`, `.mp4` and friends regardless of how the file was named, so an iPhone clip like `IMG_5732` is included.

## 2. Locate the candidate messages

File records carry no message text, so find the messages separately. Call `slack_search_public_and_private` with:

- `query`: `in:<#CH> from:<@ME> has:file`
- `content_types`: `messages`
- `sort`: `timestamp`, `sort_dir`: `desc`
- `include_context`: `false`

Paginate the same way. This search also covers messages posted as thread replies, which reading channel history alone would miss.

For each message keep its `ts`, its text, its permalink, and the `thread_ts` embedded in the permalink query string (absent for a standalone top-level message).

These results are **candidates only** — the search says a message has *some* attachment, not which one. Step 3 does the actual join.

## 3. Join files to messages — by file ID, never by timestamp

**Do not match a video to a message by comparing timestamps.** Slack's file "Created" is the *upload* time; the message that carries it is posted whenever the author finished typing, which can be many minutes later. Timestamp proximity silently assigns videos to the wrong message — verified against real data, where a video uploaded at 4:41:51 PM belonged to a 4:48:35 PM message while an unrelated video belonged to a 4:41:51 PM one.

Instead, read each candidate's message body, which lists its attachments with their file IDs:

- **Threaded candidates** — collect the distinct `thread_ts` values from step 2 and call `slack_read_thread` **once per thread** (not once per message). Every reply comes back with a `Files: <name> (ID: F…, …)` line when it has attachments.
- **Standalone candidates** — for a candidate with no `thread_ts`, call `slack_read_channel` on `<CH>` with `oldest` and `latest` bracketing its `ts` by a few seconds. The message comes back with the same `Files:` line.

From those `Files:` lines, build a map of **file ID → message** (`ts`, text, permalink). Then look up each video from step 1 in that map. The match is exact — a file ID appears on exactly one message.

Two things this must handle correctly:

- **One message, several videos.** A message can carry several attachments, so several video IDs can map to the same message. List every video, repeating the message text.
- **Unmatched video.** If a video's file ID appears on no candidate message, widen the search: `slack_read_channel` on `<CH>` with `oldest` = file created ts − 900s and `latest` = file created ts + 900s, and read any thread roots in that window with `slack_read_thread`, looking for the file ID. If it still doesn't turn up, mark the video unresolved and report it per step 4 — **never drop the video from the output, and never guess its message from a nearby timestamp.**

A message with attachments but no body text is normal (a bare upload). That is a successful match with empty text, not an unresolved one.

## 4. Output

Print a markdown table, newest first:

| Date | Message | Video | Size |
|---|---|---|---|
| 2026-07-16 5:23 PM | [Here's the quantities column on route orders](https://…permalink) | display quantities for route orders.mov | 125.9 MB |

Rules for the columns:

- **Date** — the message's local date and time.
- **Message** — the message text as a markdown link to the message permalink. Collapse newlines to spaces and truncate past ~120 characters with `…`. If the message had no text, write `_(no text)_` still linked to the permalink. If the message could not be resolved at all, write `_(message not found)_` with no link.
- **Video** — the filename, linked to the file permalink.
- **Size** — as reported by the file record.

After the table:

- If nothing was found, say so plainly — name the channel and date range that were searched, so it's clear the search wasn't simply mis-scoped.
- If any videos ended up as `_(message not found)_`, add one line naming how many and noting their file IDs turned up on no readable message — most likely the carrying message was deleted, or the file was shared into the channel from elsewhere.
- State the channel and date range covered, and confirm this only covers files uploaded to Slack — videos linked from Loom, Drive, or elsewhere are not included.
