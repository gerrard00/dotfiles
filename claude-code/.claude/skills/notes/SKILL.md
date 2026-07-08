---
description: Check local notes in ~/notes for a Jira ticket, technology, topic, filename, or general notes review before answering, create a new note when starting work, or update a note with a resume-context block when wrapping up a session. Use when the user says "check my notes", "check for my notes", "check my notes on X", "resume work on X", "resume", "pick up X", "continue X", "continue", "start work on X", "let's wrap it up for now", "that's enough for now", "wrap up", "wrapping up", "ending session", "stopping here", "calling it", "done for now", or references notes like PC-123, postgres, or another note key.
allowed-tools: Bash, Read, Glob, Grep, Write, mcp__claude_ai_Atlassian__getJiraIssue, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
---

Identify whether the user requested:

1. A specific note key or topic, such as:
   - `PC-123`
   - `postgres`
   - `billing`
   - `customer imports`

2. A resume work request, such as:
   - `resume work on PC-123`
   - `pick up my cool plan`
   - `continue billing migration`

3. A start work request, such as:
   - `start work on PC-123`
   - `start the billing migration`

4. A wrap up / end of session request, such as:
   - `let's wrap it up for now`
   - `that's enough for now`
   - `wrap up`
   - `done for now`

5. A general notes review, such as:
   - `check my notes`
   - `look at my notes`
   - `review my notes`

All notes are stored under `~/notes`.

## Specific note lookup

If the user asks for notes on a specific key or topic, prefer matches in this order:

1. Exact file match:
   - `~/notes/<query>.md`

2. Case-insensitive filename match:
   - files whose names contain the query

3. Content search:
   - files under `~/notes` whose contents mention the query

Use these tools in order:

1. `Read` — try `~/notes/<query>.md` directly (exact match).
2. `Glob` — pattern `*<query>*` in `~/notes` (case-insensitive filename match).
3. `Grep` — search for `<query>` in `~/notes` (content match).

Read the most relevant matching note or notes.

## Resume work

If the user says "resume work on X", "pick up X", "continue X", or similar — including bare forms like "resume" or "continue" with no topic:

0. If the user did not specify a key or topic:
   a. Run `git branch --show-current` (via `Bash`) to get the current branch name.
   b. Extract the first Jira-style key from the branch name using regex `[A-Za-z]+-\d+` (case-insensitive), then uppercase it. Example: `feat-pc-3382-expose-termination-effective-date` → `PC-3382`.
   c. If the command fails (not in a git repo) or no key is found in the branch name, STOP and ask the user which note to resume. Do NOT fall back to listing recent notes — that is a different intent.
   d. Otherwise, use the extracted key as X and continue with the steps below. Mention the detected key in your response so the user can correct it if wrong.

1. Extract the key or topic from the request (e.g., `PC-123`, `my cool plan`, `billing migration`).
2. Use the same file lookup logic as "Specific note lookup" to find the matching note.
3. Read the full note.
4. If the note contains a `<!-- resume-context:start --> ... <!-- resume-context:end -->` block, surface it first — it is the most recent cold-start summary and the highest-signal section for resuming.
5. Look for a TODO-like section. Match any of these headings (case-insensitive):
   - `## TODO`
   - `## Next steps`
   - `## Status`
   - `## Remaining`
   - `## Progress`
6. Present a status update:
   - The Resume context block (if present), verbatim or lightly summarized.
   - Brief summary of what the note is about.
   - What has been completed (checked items, done sections).
   - What remains (unchecked items, open tasks).
7. Do NOT start executing any tasks. Wait for the user to decide how to proceed.
8. If no TODO-like section is found, summarize the full note and mention that no explicit TODO section was found.

## Start work

If the user says "start work on X" or similar:

1. Extract the topic from the request (e.g., `PC-123`, `billing migration`).
2. Determine if X matches a Jira key pattern `[A-Z]+-\d+` (e.g., `PC-123`).
3. Derive the target filename:
   - Jira key: `~/notes/<KEY>.md` (preserve original case, e.g., `~/notes/PC-123.md`).
   - Otherwise: kebab-case slug of the topic (lowercase, spaces → hyphens, strip punctuation). Example: "billing migration" → `~/notes/billing-migration.md`.
4. Check if the file already exists using `Read`. If it does, STOP and ask the user how to proceed. Do NOT overwrite.
5. If a Jira key was detected, fetch the ticket via `mcp__claude_ai_Atlassian__getJiraIssue` to get the title and a browseable link. If the cloudId is not known, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` first.
6. Create the note with `Write`. Every note must include a `## TODO` section with one or more checkbox list items (`- [ ]`) so progress can be tracked. Template:
   - Jira key case:
     ```
     # <KEY>: <Jira title>

     <Jira browse link>

     ## TODO

     - [ ] 
     ```
   - Free-text case:
     ```
     # <Original topic as written by the user>

     ## TODO

     - [ ] 
     ```
7. Confirm to the user what was created, including the file path. Do NOT start executing the work itself — wait for the user.

## Wrap up / end of session

If the user says "let's wrap it up for now", "that's enough for now", "wrap up", "wrapping up", "ending session", "stopping here", "calling it", "done for now", or any similar phrase indicating the session is ending:

1. Identify the target note. Try in order:
   a. A note created or touched during this session — use it.
   b. Run `git branch --show-current` (via `Bash`) and extract the first Jira-style key (`[A-Za-z]+-\d+`, uppercased). Look up the matching note under `~/notes/` using the "Specific note lookup" rules.
   c. If neither works, STOP and ask the user which note to update. Do NOT guess and do NOT fall back to listing recent notes.

2. Read the current note contents (so updates merge cleanly).

3. Auto-detect the fields of the Resume context block:
   - **Updated:** today's date (`YYYY-MM-DD`).
   - **Branch:** output of `git branch --show-current`. Omit the line if not in a git repo.
   - **Where we left off:** a 1–2 sentence summary of session state, derived from what was actually discussed and changed this session (not invented).
   - **Next step:** a single concrete next action — what future-you should do first when resuming.
   - **Open questions / blockers:** if any unresolved questions or blockers came up. Omit the line if none.

4. Show the drafted Resume context block to the user for confirmation before writing. Do NOT write to the file yet.

5. Once confirmed, update the note. The block format is:

   ```
   <!-- resume-context:start -->
   ## Resume context

   - **Updated:** 2026-06-11
   - **Branch:** feat-pc-3382-expose-termination-effective-date
   - **Where we left off:** Wired up the new `terminationEffectiveDate` field in the DTO and service, but the integration test for cancellations is still failing on date-only comparison.
   - **Next step:** Fix `cancellations.spec.ts` by normalising the expected date to `YYYY-MM-DD` before comparing.
   - **Open questions / blockers:** None.
   <!-- resume-context:end -->
   ```

   Placement rules:
   - If a `<!-- resume-context:start --> ... <!-- resume-context:end -->` block already exists in the file, replace it in place (do not append a new one).
   - Otherwise, insert the block immediately after the title (and the Jira browse link, if present) and before the next section.

6. Also refresh the `## TODO` section per "Updating an existing note": mark completed items as `- [x]`, add any newly identified follow-ups as `- [ ]`. If the note is missing a `## TODO` section, add one.

7. Confirm to the user what was written, including the file path and a brief summary of the Resume context. Do NOT commit, push, stage, or otherwise touch git state — notes only.

## Updating an existing note

When adding content to an existing note (e.g., after agreeing on a plan, completing a step, or identifying follow-ups), keep the `## TODO` section as the canonical progress tracker. Add new items as `- [ ]`, mark completed items as `- [x]`, and only remove items when they are no longer relevant. If a note is missing a `## TODO` section, add one.

## General notes review

If the user says only "check my notes" or asks for notes in general, inspect recent and relevant notes under `~/notes`.

Start by listing markdown files:

1. `Glob` — pattern `*.md` in `~/notes` (returns files sorted by modification time).

Then read the most relevant recent notes. Prefer files that appear related to the current conversation, active task, branch name, Jira ticket, error, project, or technology being discussed.

If there is no clear current context, summarize the most recently modified notes.

## Answering rules

- Mention which note file or files were used.
- Prefer exact filename matches over filename partial matches.
- Prefer filename matches over content matches.
- For general checks, prefer recent notes and notes relevant to the current conversation.
- If multiple likely notes exist, summarize the most relevant ones.
- If no matching or useful notes are found, say that clearly.
- Do not invent notes or assume content that was not read.
