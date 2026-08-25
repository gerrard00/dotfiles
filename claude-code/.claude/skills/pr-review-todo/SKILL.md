---
name: pr-review-todo
description: Build Gerrard's PR review TODO list from the pod-c code reviews Slack channel. Finds threads from the last 48 hours started by someone else that he has neither replied to nor reacted to, extracts the PR link from each, drops PRs he has already commented on or reviewed on GitHub as well as PRs that are merged or already have two approvals, and prints a table (author, repo, PR#, lines changed, link). Read-only — never posts anything. Use when the user says "pr review todo", "/pr-review-todo", "what PRs do I need to review", "review todo", "any PRs to review?", "let's review some PRs", "PR review time", or otherwise asks what PRs are waiting on his review.
allowed-tools: Bash, Read, Write, mcp__claude_ai_Slack__slack_read_channel, mcp__claude_ai_Slack__slack_read_thread, mcp__claude_ai_Slack__slack_get_reactions, mcp__claude_ai_Slack__slack_read_user_profile, mcp__claude_ai_Slack__slack_search_channels, mcp__claude_ai_Slack__slack_search_users
---

Produce a TODO list of PRs Gerrard still needs to review. This skill is strictly read-only with respect to Slack and GitHub: it never sends Slack messages, reactions, or GitHub comments. (It does write the local ID cache described in step 0.)

## Fixed context

- **Slack channel:** `#pod-c-code-reviews`. Only this channel — do not check `#code-reviews`.
- **GitHub org:** `curbsidetechnologies`. Repos: `curbwaste-web`, `curbwaste-apis`, `curbwaste-backend`.
- **Gerrard's GitHub login:** resolve once at the start with `gh api user --jq .login`.

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

Read the cache with `Read` (or `cat` via Bash). A missing file, unparseable JSON, or a missing/empty key is **not an error** — it just means that value has to be resolved. Never fail the skill because of the cache. This skill only needs `self_user_id` and the `pod-c-code-reviews` channel ID; leave any other cached keys as they are.

Resolve whatever is missing:

- **Channel ID** — `mcp__claude_ai_Slack__slack_search_channels` with `pod-c-code-reviews` as the query; take the ID of the exact name match.
- **Gerrard's own Slack user ID** — get his identity from local machine config rather than hardcoding it: run `git config --global user.name` (fall back to `git config --global user.email` if the name is empty), then pass that value as the query to `mcp__claude_ai_Slack__slack_search_users` and take the single matching user's ID. If neither config value resolves to exactly one user, ask him which account is his rather than guessing.

After resolving, rewrite the whole cache file with `Write` so all known values are persisted for next time. Referred to below as **the resolved channel ID** and **Gerrard's Slack user ID (resolved above)**.

## 1. Collect candidate threads from Slack

Read `#pod-c-code-reviews` (its resolved channel ID) with `slack_read_channel`, paging with the cursor until messages are older than 48 hours from now. Keep only **top-level messages** (thread roots or standalone posts) that are:

- posted within the last 48 hours, and
- posted by someone **other than** Gerrard's Slack user ID (resolved above).

For each kept message, rule it out if Gerrard has already engaged:

- **Replied:** read the thread with `slack_read_thread` (channel + root `ts`). If any reply is from Gerrard's Slack user ID (resolved above), drop the thread. (A standalone message with no replies needs no thread read.)
- **Reacted:** check reactions on the **root message** with `slack_get_reactions`. If any reaction includes Gerrard's Slack user ID (resolved above), drop the thread.

The survivors are the **candidates**.

## 2. Extract PR links and apply the 10-thread cap

For each candidate, find a GitHub PR URL matching `github.com/curbsidetechnologies/<repo>/pull/<number>`. Look in the root message first, then in thread replies. Slack stores links as `<url>` or `<url|text>`; strip that wrapping and any trailing slash or query string. Candidates with no PR link go to the "no PR link" note in step 4 — they do **not** count toward the cap.

Never process more than 10 threads that have a PR link. If more than 10 candidates have one, sort by root-message `ts` ascending and keep the **10 oldest**. Remember the total count of PR-link candidates `X` — if `X > 10`, the final output must end with the line:

> Only 10 of X threads processed.

Step 3 applies only to the (at most 10) selected threads.

## 3. Check GitHub

For each selected PR, run:

```
gh pr view <number> --repo curbsidetechnologies/<repo> --json url,author,additions,deletions,comments,reviews,state
```

Drop the PR from the list if it no longer needs his review:

- **Merged:** `state` is `MERGED`.
- **Already has two approvals:** at least 2 distinct reviewers whose **latest** review in `reviews` has `state` = `APPROVED` (a dismissed or superseded approval doesn't count).

Also drop it if Gerrard already engaged on GitHub, i.e. if either:

- any entry in `comments` has `author.login` equal to his GitHub login, or
- any entry in `reviews` has `author.login` equal to his GitHub login.

Otherwise it belongs on the TODO list. Record:

- **Author** — the Slack thread poster's real name (via `slack_read_user_profile`; fall back to the PR author's login if the profile lookup fails).
- **Repo** — the repo name from the URL.
- **PR#** — the PR number.
- **Lines changed** — `additions + deletions`.
- **Link** — the PR URL.

## 4. Output

Print a markdown table sorted oldest thread first:

| Author | Repo | PR | Lines changed |
|---|---|---|---|
| Jane Doe | curbwaste-web | [#123](https://github.com/curbsidetechnologies/curbwaste-web/pull/123) | 245 |

After the table:

- If any candidates had no PR link, add a short bullet list: "No PR link found: <Slack message link or first line of the post>". These are outside the cap, so list all of them.
- If every candidate was already handled (empty table), say so plainly.
- If `X > 10`, end with exactly: `Only 10 of X threads processed.` (with X replaced by the real count).
