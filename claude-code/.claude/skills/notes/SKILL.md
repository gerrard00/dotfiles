---
description: Check local notes in ~/notes for a Jira ticket, technology, topic, filename, or general notes review before answering, create a new note when starting work, or update a note with a resume-context block when wrapping up a session. Use when the user says "check my notes", "check for my notes", "check my notes on X", "resume work on X", "resume", "pick up X", "continue X", "continue", "start work on X", "let's wrap it up for now", "that's enough for now", "wrap up", "wrapping up", "ending session", "stopping here", "calling it", "done for now", or references notes like PC-123, postgres, or another note key. Also use when the user says "prune my notes", "reconcile open questions", "clean up my notes", "dedupe my notes", or asks to remove stale, answered, or duplicated open questions.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit, mcp__claude_ai_Atlassian__getJiraIssue, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources
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

6. A prune / reconcile request, such as:
   - `prune my notes`
   - `reconcile open questions`
   - `clean up PC-123`
   - `dedupe the open questions`

   Run "Reconciling open questions" against the note, standalone. Do not touch the
   Resume context block, the TODO section, or the active ticket state.

All notes are stored under `~/notes`.

## Note names

Every target is either a Jira key or a free-text name. Classify it before using it anywhere — filename,
note title, status line, lookup.

1. **Jira key.** If the extracted target matches `^[A-Za-z]+-\d+$`, it is a Jira key. Uppercase it
   (`pc-123` → `PC-123`) and use it as is.
2. **Free-text name.** Anything else is normalized to a slug, regardless of how the user typed it:
   - lowercase it;
   - replace every run of characters outside `a-z0-9` with a single `-`;
   - trim leading and trailing `-`.

   Examples: `Foo Bar` → `foo-bar`; `foo  bar!!` → `foo-bar`; `Foo/Bar v2` → `foo-bar-v2`.
3. **Empty slug.** If normalizing leaves nothing (`!!!`), STOP and ask the user for a name.

The slug is the only form a free-text name is saved or displayed in: the file is `~/notes/<slug>.md`,
the note's `#` title is the slug, and the status line shows the slug. Never keep the user's original
spelling alongside it.

## Session state (status line)

The status line shows the target for the current session (a Jira key or a free-text slug), and whether a wrap up is waiting on approval. It is driven **only** by this skill — never by the git branch. State lives per-session, managed by the helper `~/.claude/set-active-ticket.sh`. Always change it through that helper (via `Bash`) — never write the state file directly.

- **Set** it when starting or resuming work on any target (see those flows below):

  ```
  ~/.claude/set-active-ticket.sh <TARGET>
  ```

  Use the form from "Note names": the uppercased Jira key (e.g. `PC-123`) or the slug (e.g. `foo-bar`).
- **Clear** it on wrap up (no argument):

  ```
  ~/.claude/set-active-ticket.sh
  ```

### Wrap up pending

A second per-session marker, managed by `~/.claude/set-wrapup-pending.sh`, renders `wrap up pending`
in yellow after the context percentage. Change it only through that helper (via `Bash`).

- **Set** it once the drafted Resume context block is on screen awaiting approval (wrap up step 4):

  ```
  ~/.claude/set-wrapup-pending.sh 1
  ```

- **Clear** it (no argument) once the write is applied, or as soon as the user abandons the wrap up
  and carries on working:

  ```
  ~/.claude/set-wrapup-pending.sh
  ```

A plain note lookup or general review must NOT change either piece of state.

## Detecting the session target

Use this when the user gave no key or topic — a bare `resume` / `continue`, or a wrap up with no
target. Try the sources in order and stop at the first hit.

1. **tmux session name.** If `$TMUX` is set, run (via `Bash`):

   ```
   tmux display-message -p -t "$TMUX_PANE" '#S'
   ```

   (If `$TMUX_PANE` is empty, drop the `-t` argument.) The session name is a hit if **either**:
   - it matches `^[A-Za-z]+-\d+$` — a Jira key. Uppercase it and use it as the key; or
   - normalizing it per "Note names" gives a slug and `~/notes/<slug>.md` exists — use that note
     as a free-text target. A session named `Foo Bar` finds `~/notes/foo-bar.md`.

   The key regex is anchored on purpose: the whole session name must be the key, so a session
   named `curbwaste-backend-2` is not read as `BACKEND-2`. Names that are neither a key nor an
   existing note (`bugs`, `agent-skill-share`) are not a hit — fall through to the branch.
2. **Git branch.** Run `git branch --show-current` (via `Bash`) and extract the first Jira-style
   key from the branch name using regex `[A-Za-z]+-\d+` (case-insensitive), then uppercase it.
   Example: `feat-pc-123-some-feature-name` → `PC-123`. This step only finds Jira keys —
   free-text work has no branch, so it is found by tmux session name or not at all.
3. **Neither.** STOP and ask the user which note to use. Do NOT fall back to listing recent notes
   — that is a different intent.

Always mention the detected target in your response so the user can correct it if it is wrong.

**On disagreement:** if the tmux session gave a hit and the branch *also* yields a Jira key that
differs from it, prefer the tmux value and name both — e.g. "Using PC-1234 (tmux session); the
branch says PC-4026."

## Specific note lookup

If the user asks for notes on a specific key or topic, first classify the query per "Note names". Below,
`<name>` is the uppercased Jira key or the slug. Prefer matches in this order:

1. Exact file match:
   - `~/notes/<name>.md`

2. Case-insensitive filename match:
   - files whose names contain `<name>`

3. Content search:
   - files under `~/notes` whose contents mention the query

Use these tools in order:

1. `Read` — try `~/notes/<name>.md` directly (exact match).
2. `Glob` — pattern `*<name>*` in `~/notes` (case-insensitive filename match).
3. `Grep` — search for the query as the user typed it, and for `<name>`, in `~/notes` (content match).

Read the most relevant matching note or notes.

## Resume work

If the user says "resume work on X", "pick up X", "continue X", or similar — including bare forms like "resume" or "continue" with no topic:

0. If the user did not specify a key or topic, run "Detecting the session target" to find X, then
   continue with the steps below.

1. Extract the key or topic from the request (e.g., `PC-123`, `my cool plan`, `billing migration`) and classify it per "Note names".
2. Use the same file lookup logic as "Specific note lookup" to find the matching note.
2a. Set the active ticket state file (see "Session state") to the uppercased Jira key or the slug so the status line reflects this session's work.
3. Read the full note.
4. If the note contains a `<!-- resume-context:start --> ... <!-- resume-context:end -->` block, surface it first — it is the most recent cold-start summary and the highest-signal section for resuming.
4a. Read the `## Open questions` section and surface it immediately after the Resume context block. That section is the only authority on what is still unresolved. If the note phrases something as open **outside** that section — "OPEN QUESTION", "TBD", "awaiting", "we believe", "not settled" — do not treat it as live. Treat it as a reconcile bug: check it against `## Decisions`, say so, and offer to run "Reconciling open questions".
5. Look for a TODO-like section. Match any of these headings (case-insensitive):
   - `## TODO`
   - `## Next steps`
   - `## Status`
   - `## Remaining`
   - `## Progress`
6. Present a status update:
   - The Resume context block (if present), verbatim or lightly summarized.
   - The `## Open questions` entries, if any.
   - Brief summary of what the note is about.
   - What has been completed (checked items, done sections).
   - What remains (unchecked items, open tasks).
7. Do NOT start executing any tasks. Wait for the user to decide how to proceed.
8. If no TODO-like section is found, summarize the full note and mention that no explicit TODO section was found.

## Start work

If the user says "start work on X" or similar:

1. Extract the topic from the request (e.g., `PC-123`, `billing migration`).
2. Classify it per "Note names".
3. Derive the target filename:
   - Jira key: `~/notes/<KEY>.md` (uppercased, e.g., `~/notes/PC-123.md`).
   - Otherwise: `~/notes/<slug>.md`. Example: "Billing Migration!" → `~/notes/billing-migration.md`.
4. Check if the file already exists using `Read`. If it does, STOP. Do NOT overwrite. Warn the user that
   the name collides — for a free-text name, show what they typed and the slug it normalized to, since
   different inputs (`Foo Bar`, `foo/bar`) land on the same file — then show the existing note's title
   and Resume context (if any), and ask whether to resume that note or pick a different name.
5. If a Jira key was detected, fetch the ticket via `mcp__claude_ai_Atlassian__getJiraIssue` to get the title and a browseable link. If the cloudId is not known, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` first.
6. Create the note with `Write`. Every note must include a `## TODO` section with one or more checkbox list items (`- [ ]`) so progress can be tracked. Template:
   - Jira key case:
     ```
     # <KEY>: <Jira title>

     <Jira browse link>

     ## TODO

     - [ ] 

     ## Open questions

     _None yet._

     ## Decisions

     _None yet._
     ```
   - Free-text case:
     ```
     # <slug>

     ## TODO

     - [ ] 

     ## Open questions

     _None yet._

     ## Decisions

     _None yet._
     ```
7. Set the active ticket state file (see "Session state") to the uppercased Jira key or the slug so the status line reflects this session's work.
8. Confirm to the user what was created, including the file path. Do NOT start executing the work itself — wait for the user.

## Wrap up / end of session

If the user says "let's wrap it up for now", "that's enough for now", "wrap up", "wrapping up", "ending session", "stopping here", "calling it", "done for now", or any similar phrase indicating the session is ending:

1. Identify the target note. Try in order:
   a. A note created or touched during this session — use it.
   b. Run "Detecting the session target", then look up the matching note under `~/notes/` using the "Specific note lookup" rules.
   c. If neither works, STOP and ask the user which note to update. Do NOT guess and do NOT fall back to listing recent notes.

2. Read the current note contents (so updates merge cleanly).

2a. Run "Reconciling open questions" steps 1–4 over the note and its siblings, but do not write yet. This
   is not optional and it is not limited to questions raised this session — a wrap up is the checkpoint
   where the note must stop contradicting itself. It runs before the Resume context block is drafted, so
   that block reports the reconciled state rather than a stale one.

3. Auto-detect the fields of the Resume context block:
   - **Updated:** today's date (`YYYY-MM-DD`).
   - **Branch:** output of `git branch --show-current`, for Jira-key notes only. Omit the line for
     free-text notes (they have no branch, so the current one is unrelated) and when not in a git repo.
   - **Where we left off:** a 1–2 sentence summary of session state, derived from what was actually discussed and changed this session (not invented).
   - **Next step:** a single concrete next action — what future-you should do first when resuming.
   - **Blockers:** anything preventing progress that is not a question. Omit the line if none.
   - **Open questions:** a count and a pointer, never the questions themselves — `2 open, see "Open questions"`. Restating them here creates the second record that goes stale. Omit the line when the section is empty. Derive the count from `## Open questions` as reconciled in step 2a, not from memory of the session.

4. Show the user, in one message, both the drafted Resume context block and the reconcile change list from
   step 2a (per "Reconciling open questions" step 5). Get confirmation before writing. Do NOT write to the
   file yet. Set the wrap up pending marker (see "Session state") in the same turn the draft goes up, so
   the status line shows the write is still outstanding. If the user declines the wrap up or resumes
   working instead, clear it.

5. Once confirmed, apply the reconcile changes and update the note. The block format is:

   ```
   <!-- resume-context:start -->
   ## Resume context

   - **Updated:** 2026-06-11
   - **Branch:** feat-pc-123-some-feature-name
   - **Where we left off:** Wired up the new field in the DTO and service, but the integration test is still failing on a date-only comparison.
   - **Next step:** Fix the failing spec by normalising the expected date to `YYYY-MM-DD` before comparing.
   - **Open questions:** 2 open, see "Open questions".
   <!-- resume-context:end -->
   ```

   Placement rules:
   - If a `<!-- resume-context:start --> ... <!-- resume-context:end -->` block already exists in the file, replace it in place (do not append a new one).
   - Otherwise, insert the block immediately after the title (and the Jira browse link, if present) and before the next section.

6. Also refresh the `## TODO` section per "Updating an existing note": mark completed items as `- [x]`, add any newly identified follow-ups as `- [ ]`. If the note is missing a `## TODO` section, add one.

7. Clear the active ticket state file and the wrap up pending marker (see "Session state") so the status line goes blank until work is next started or resumed.
8. Confirm to the user what was written: the file path, a brief summary of the Resume context, and what
   the reconcile pass changed (questions resolved, duplicates merged, stale blocks deleted, files touched).
   Do NOT commit, push, stage, or otherwise touch git state of any code repository. In `~/notes`, only
   the commits described in "Recoverability" are made.

## Updating an existing note

When adding content to an existing note (e.g., after agreeing on a plan, completing a step, or identifying follow-ups), keep the `## TODO` section as the canonical progress tracker. Add new items as `- [ ]`, mark completed items as `- [x]`, and only remove items when they are no longer relevant. If a note is missing a `## TODO` section, add one.

New questions go in `## Open questions` and nowhere else — check the section first, since the question may already be recorded there under different wording or nested under a parent.

The moment a question is answered mid-session, run "Reconciling open questions" steps 2–5 for that question. Do not defer it to wrap up: a note that records an answer in one place while still asking the question in another is worse than a note that never recorded the answer.

## Open questions and decisions

A note has exactly one `## Open questions` section, and it is the only place an unresolved question may
live. Nothing else in the note gets to declare something open.

- Entries are `- [ ]` checkboxes, one question per entry, phrased as a question.
- A question that is genuinely narrower than another nests under it as an indented `- [ ]`. Nesting is for
  decomposition only — a sub-question must be answerable without answering its parent. If it is just the
  parent restated in other words, it is a duplicate, not a sub-question.
- Elsewhere in the note, **cite** a question, never restate it: `See "Open questions" → <question>`. A
  second copy of the question text is the bug this section exists to prevent.
- When a question is answered it leaves `## Open questions` entirely — it is deleted from that section, not
  checked off in place — and lands in `## Decisions` as:

  ```
  - **2026-08-25 — Should the importer retry the whole batch on a partial failure?** No. Ruled by
    Gerrard; it retries only the rows that failed.
  ```

- `## Decisions` is append-only history and is the answer's single home. Do not also record the answer next
  to where the question used to be.

## Reconciling open questions

Run this on wrap up, whenever a question is answered mid-session, and on an explicit prune request. The
goal is one record per question — no duplicates inside `## Open questions`, no stale copies outside it.

**Scope.** The target note plus its siblings: glob `~/notes/<KEY>-*.md` when the note is a Jira key (e.g.
`PC-123.md` pulls in `PC-123-test-plan.md`, `PC-123-execution-status.md`, `PC-123-gate-matrix.md`).
For a free-text note, glob `~/notes/<slug>-*.md`. A slug can be the prefix of an unrelated topic
(`billing` matches `billing-migration.md`), so if that glob returns anything, STOP before reading the
matches: warn the user, list them, and ask which belong to this note. Include only the ones they confirm.
Do not sweep all of `~/notes` — unrelated tickets produce false matches.

0. **Adopt the section if missing.** Older notes predate this convention. If the note has no
   `## Open questions` section, create one (immediately after the Resume context block) and move every
   still-unresolved question found in the body into it — the block itself is deleted from the body, leaving
   a citation only where the surrounding prose needs one. Add `## Decisions` too if absent. Questions the
   body already answers skip straight to `## Decisions`; they never pass through `## Open questions`.

1. **Collect what was answered.** List every question settled this session, plus anything already in
   `## Decisions` that the sweep in step 4 shows is still being asked somewhere.

2. **Dedupe inside `## Open questions`.** Compare every entry against every other entry — top-level against
   top-level, top-level against nested, and nested against nested under a different parent. Two entries
   that would be closed by the same answer are duplicates regardless of wording. For each duplicate pair:
   - Keep one entry. Prefer the wording that is most specific about what is actually being decided.
   - Keep it nested only if it is genuinely narrower than its parent per the nesting rule above. Otherwise
     promote it to top level and delete the nested copy.
   - If one copy carries context the survivor lacks, fold that context into the survivor before deleting.
   Do this even when nothing was answered this session — a question duplicated across two parents will
   otherwise be answered twice and pruned once.

3. **Retire what was answered.** Delete each answered entry from `## Open questions` and add a
   `## Decisions` line with the date, the question, and the ruling. Deleting a parent whose sub-questions
   are still open is wrong — resolve or re-parent them first.

4. **Sweep the bodies.** Search the target note and its siblings for restatements of anything now in
   `## Decisions`. Look for the question's subject alongside open-state markers, case-insensitive:
   `OPEN QUESTION`, `TBD`, `awaiting`, `pending`, `unresolved`, `not settled`, `we believe`, `we think`,
   `needs a decision`, `?` headings, and warning banners (`⚠️`, `⛔`, `> **NOTE**`) bolted on top of an
   older block. For each hit:
   - **Delete** any sentence, bullet, block, or banner that asserts a disposition which is no longer true —
     that the question is open, awaiting an answer, or that the answer is a guess.
   - **Keep** evidence and mechanism: findings, measurements, repro steps, file and line references, the
     explanation of *why* the answer is what it is. Reword only where a kept sentence's framing depends on
     the question still being open.
   - A block that is *entirely* a stale open-question record goes away completely. Do not preserve it
     behind a "this is history" banner — that pattern is what makes answered questions read as open.
   - Replace the deleted text with a citation to the `## Decisions` line where the surrounding prose still
     needs to point at the ruling.

5. **Confirm, then write.** Present the proposed changes as a list before touching any file:
   - duplicates merged — which entry survives, which is deleted;
   - questions retired to `## Decisions`;
   - each body deletion as `<file> → <heading> → <first line of the block>` plus a line count.

   Write only after the user confirms. When a hit is ambiguous — the wording is open-ended but might be a
   different question — list it as a question for the user instead of deleting it.

   Before deleting anything, follow "Recoverability" below. A wrong deletion in an untracked note is
   unrecoverable.


## Recoverability

`~/notes` is a git repository on branch `master`, and every note is tracked: the note, its siblings, and
its evidence folder (`~/notes/<KEY>/`). Git is the only recovery mechanism.

Before any destructive edit (deleting a section, rewriting a block, reconciling open questions), make sure
the files you are about to touch are committed:

```
GIT_DIR=/Users/gerrard/notes/.git GIT_WORK_TREE=/Users/gerrard/notes \
  git status --short -- <files>
```

- **Clean**: proceed. `git diff -- <file>` shows what you changed and `git checkout -- <file>` restores it.
- **Untracked (`??`) or modified (`M`)**: `git add` and `git commit` those files first, then edit.

`~/notes/junk/` is the only place for files that must not be tracked: ad hoc backups, scratch copies,
throwaway notes. `junk` is ignored by the global gitignore. Never copy notes aside to the scratchpad or
any other folder as a backup; commit them instead.

### Deleting by string index is the hazard that has actually bitten

Slicing a file between two located strings deletes everything in between, including sections you never
intended to touch. A section title such as `## Message to product and QA` also appears inside the Resume
context's **Next step** line, so `s.index(title)` lands on the citation, not the heading, and the cut runs
from there to the next anchor. This destroyed a note's TODO, Open questions and two other sections on
2026-09-30.

Anchor on a line-start heading (`\n## <title>\n`), and after writing, re-read the headings
(`grep -n '^## ' <file>`) to confirm only the intended section changed.

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
