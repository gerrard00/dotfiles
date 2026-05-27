---
description: Check local notes in ~/notes for a Jira ticket, technology, topic, filename, or general notes review before answering, or create a new note when starting work. Use when the user says "check my notes", "check for my notes", "check my notes on X", "resume work on X", "pick up X", "continue X", "start work on X", or references notes like PC-123, postgres, or another note key.
allowed-tools: Read, Glob, Grep, Write, mcp__claude_ai_Atlassian__getJiraIssue, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
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

3. A general notes review, such as:
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

If the user says "resume work on X", "pick up X", "continue X", or similar:

1. Extract the key or topic from the request (e.g., `PC-123`, `my cool plan`, `billing migration`).
2. Use the same file lookup logic as "Specific note lookup" to find the matching note.
3. Read the full note.
4. Look for a TODO-like section. Match any of these headings (case-insensitive):
   - `## TODO`
   - `## Next steps`
   - `## Status`
   - `## Remaining`
   - `## Progress`
5. Present a status update:
   - Brief summary of what the note is about.
   - What has been completed (checked items, done sections).
   - What remains (unchecked items, open tasks).
6. Do NOT start executing any tasks. Wait for the user to decide how to proceed.
7. If no TODO-like section is found, summarize the full note and mention that no explicit TODO section was found.

## Start work

If the user says "start work on X" or similar:

1. Extract the topic from the request (e.g., `PC-123`, `billing migration`).
2. Determine if X matches a Jira key pattern `[A-Z]+-\d+` (e.g., `PC-123`).
3. Derive the target filename:
   - Jira key: `~/notes/<KEY>.md` (preserve original case, e.g., `~/notes/PC-123.md`).
   - Otherwise: kebab-case slug of the topic (lowercase, spaces → hyphens, strip punctuation). Example: "billing migration" → `~/notes/billing-migration.md`.
4. Check if the file already exists using `Read`. If it does, STOP and ask the user how to proceed. Do NOT overwrite.
5. If a Jira key was detected, fetch the ticket via `mcp__claude_ai_Atlassian__getJiraIssue` to get the title and a browseable link. If the cloudId is not known, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` first.
6. Create the note with `Write`. Template:
   - Jira key case:
     ```
     # <KEY>: <Jira title>

     <Jira browse link>
     ```
   - Free-text case:
     ```
     # <Original topic as written by the user>
     ```
7. Confirm to the user what was created, including the file path. Do NOT start executing the work itself — wait for the user.

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
