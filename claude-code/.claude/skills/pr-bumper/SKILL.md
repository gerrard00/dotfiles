---
name: pr-bumper
description: Keep Gerrard's open PRs visible in the pod-c code reviews Slack channel. Finds his open, ready-for-review PRs on GitHub (all three Curbwaste repos, or just the current branch's PR), checks whether each has a post from him in the code-reviews channels, offers to post missing ones, and offers to bump stale threads (last comment from him >4h old) with a random phrase from phrases.md. Use when the user says "pr bumper", "/pr-bumper", "bump my prs", "bump the current pr", "bump the pr", or "bump this".
allowed-tools: Bash, Read, Write, AskUserQuestion, mcp__claude_ai_Slack__slack_read_channel, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_send_message, mcp__claude_ai_Slack__slack_search_channels, mcp__claude_ai_Slack__slack_search_users
---

Surface Gerrard's ready-for-review PRs in Slack: post links for PRs that haven't been posted yet, and bump threads that have gone quiet. Never post or bump anything without an explicit yes via AskUserQuestion first.

## Fixed context

- **GitHub org:** `curbsidetechnologies`. Repos: `curbwaste-web`, `curbwaste-apis`, `curbwaste-backend`.
- **Primary Slack channel (where new posts go):** `#pod-c-code-reviews`.
- **Secondary Slack channel (check only, never post):** `#code-reviews`. Team posts occasionally land here, so existing posts must be searched for in both channels.
- **Phrases file:** `~/.claude/skills/pr-bumper/phrases.md` (one phrase per line; ignore the header lines and blank lines).

## 0. Resolve Slack IDs (cached)

Slack channel and user IDs are not stored in this repo — resolve them at runtime and cache them.

**Cache file:** `${TMPDIR:-/tmp}/claude-pod-c-ids.json`, shaped:

```json
{
  "self_user_id": "<Slack user ID>",
  "channels": {
    "pod-c-code-reviews": "<channel ID>",
    "code-reviews": "<channel ID>"
  }
}
```

Read the cache with `Read` (or `cat` via Bash). A missing file, unparseable JSON, or a missing/empty key is **not an error** — it just means that value has to be resolved. Never fail the skill because of the cache.

Resolve whatever is missing:

- **Channel IDs** — `mcp__claude_ai_Slack__slack_search_channels` with the channel name (`pod-c-code-reviews`, `code-reviews`) as the query; take the ID of the exact name match.
- **Gerrard's own Slack user ID** — get his identity from local machine config rather than hardcoding it: run `git config --global user.name` (fall back to `git config --global user.email` if the name is empty), then pass that value as the query to `mcp__claude_ai_Slack__slack_search_users` and take the single matching user's ID. If neither config value resolves to exactly one user, ask him which account is his rather than guessing.

After resolving, rewrite the whole cache file with `Write` so all known values are persisted for next time. Referred to below as **the resolved channel IDs** and **Gerrard's Slack user ID (resolved above)**.

## 1. Determine mode and collect PRs

**Current-PR mode** — if the request references a single/current PR ("current pr", "this pr", "bump the pr", "bump this"):

- Identify the repo from the CWD directory name. Strip a `-parallel` or `-review` suffix (those are work trees of the same repo). If the CWD is not inside one of the three repos, STOP and ask which repo/PR is meant.
- Run `git branch --show-current`, then:
  `gh pr list --repo curbsidetechnologies/<repo> --head <branch> --state open --json number,title,url,isDraft,createdAt,author`
- If there is no open PR for the branch, report that and stop. Do NOT apply the two-week or draft filters in this mode — the user pointed at this PR explicitly; just note it if the PR is a draft.

**All-repos mode** — otherwise, for each of the three repos run:

```
gh pr list --repo curbsidetechnologies/<repo> --author @me --state open --json number,title,url,isDraft,createdAt,author
```

Keep PRs where `isDraft` is false and `createdAt` is within the last 14 days. If nothing survives the filter, report "no open ready-for-review PRs from the last two weeks" and stop.

## 2. Find existing posts in Slack

For each of the two resolved channel IDs (`#pod-c-code-reviews` and `#code-reviews`), read the last 7 days of messages with `slack_read_channel` (page with the cursor until messages are older than 7 days). For each PR, look for a **top-level message from Gerrard's Slack user ID (resolved above)** whose text contains the PR URL. Match loosely: Slack stores links as `<url>` or `<url|text>`, and a trailing slash or query string may differ — match on `github.com/curbsidetechnologies/<repo>/pull/<number>`.

Classify each PR as:

- **Posted** — a matching message from Gerrard exists (in either channel). Record its channel, `ts`, and whether it has replies.
- **Not posted** — no matching message from Gerrard in either channel. (A post from someone else does not count.)

## 3. Not-posted PRs → offer to post

If any PRs are unposted, use AskUserQuestion (multiSelect) listing each unposted PR by title, plus the option to post all of them. For each PR the user selects, send **one separate message per PR** to `#pod-c-code-reviews` (its resolved channel ID) via `slack_send_message` with `unfurl_app_links: true`. The message body is exactly a markdown link whose text mirrors GitHub's own page title, using the middle-dot separator ` · `:

```
[<PR title> by <author login> · Pull Request #<PR number> · curbsidetechnologies/<repo>](<PR URL>)
```

For example:

```
[feat: PC-3387 expose route id on driver jobs feed by gerrard00 · Pull Request #3122 · curbsidetechnologies/curbwaste-backend](https://github.com/curbsidetechnologies/curbwaste-backend/pull/3122)
```

`<author login>` comes from the PR data at runtime — the `author.login` field of the `gh pr list` output. Never hardcode a login.

No extra commentary, no emoji, nothing else in the message.

## 4. Posted PRs → check staleness and offer to bump

For each posted PR, read its thread with `slack_read_thread` (channel + the post's `ts`). Find the **latest message in the thread from Gerrard's Slack user ID (resolved above)** — the root post counts if he has no replies. If that message is **more than 4 hours old**, the thread is stale.

If any threads are stale, use AskUserQuestion (multiSelect) listing each stale PR by title with how long ago his last message was, plus an option to bump all. For each PR the user approves:

- Pick a random phrase from the phrases file:
  ```
  grep -v '^#' ~/.claude/skills/pr-bumper/phrases.md | grep -v '^$' | sort -R | head -1
  ```
  Draw a fresh phrase for each bump so multiple bumps in one run vary.
- Send it as a thread reply that also posts to the channel: `slack_send_message` with `channel_id` = the channel the post lives in, `thread_ts` = the root post's `ts`, `reply_broadcast: true`, and `message` = the phrase verbatim.

Threads whose last Gerrard message is under 4 hours old get no bump offer — just mention them as "recently active" in the summary.

## 5. Summary

Finish with a short per-PR summary: posted now / bumped now / already posted and recently active / user declined. Include the Slack message links returned by `slack_send_message` for anything sent.
