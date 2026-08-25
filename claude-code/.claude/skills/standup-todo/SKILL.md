---
name: standup-todo
description: Daily standup helper for ~/notes/standup.md. On every invocation it reports the previous day's goal, asks for today's goal if one hasn't been set yet (stored in ~/notes/goals.md), prunes completed TODOs from the `# Today` section once per day, and optionally adds a new `- [ ]` TODO item. Use when the user says "standup", "add a todo", "standup todo", "add to standup", "todo for today", "note for standup", or "/standup-todo".
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

Daily standup helper for `~/notes/standup.md` and `~/notes/goals.md`.

Every invocation runs steps 1–4 in order. Step 5 (adding a TODO) only runs if the user provided item text after the trigger.

## 1. Get today's date and read the files

Run `date +%F` to get today's date (never assume it). `Read` both `~/notes/standup.md` and `~/notes/goals.md`.

- If `standup.md` does not exist, STOP and tell the user — do not create it from scratch.
- If `goals.md` does not exist, create it with `Write` using this skeleton (no goal entries yet):

```markdown
---
last-pruned: <never>
---

# Goals
```

`goals.md` stores one entry per day, newest first:

```markdown
---
last-pruned: 2026-08-12
---

# Goals

## 2026-08-12

<goal text>

## 2026-08-11

<goal text>
```

## 2. Prune completed TODOs — once per day only

Compare the `last-pruned` date in `goals.md` frontmatter to today's date.

- If `last-pruned` is already today, skip this step entirely.
- Otherwise: in the `# Today` section of `standup.md`, remove every top-level item marked done (`- [x]`) **together with its indented child lines**. Leave done sub-items under an unchecked parent alone — only remove at the top level. Do not touch anything outside the `# Today` section.
- Then update `last-pruned` in `goals.md` to today's date, even if there was nothing to remove (so the check doesn't rerun today).
- Tell the user which items were removed (or that none were done).

## 3. Report the previous goal

Find the most recent entry in `goals.md` dated **before** today (it may be several days back — weekends, days off). Tell the user what that goal was, e.g. "Your last daily goal (2026-08-11) was: …".

If `goals.md` has no prior entries but the `# Daily Goal` section in `standup.md` contains text (first run / migration), treat that text as the previous goal and report it instead.

## 4. Ask for today's goal — only if not already set

Check whether `goals.md` has an entry for today's date.

- **Already set:** do NOT ask again. Just restate today's goal briefly and move on.
- **Not set:** ask the user what their goal for today is. When they answer:
  - Insert a new `## <today>` entry at the top of the `# Goals` list in `goals.md` (below the frontmatter and `# Goals` heading, above older entries) with their goal text verbatim.
  - If the user explicitly says they have no goal today, record the entry with the text `(none)` so they are not asked again today.
- After any change, rewrite the `# Daily Goal` section of `standup.md` so it always shows the current and previous goal:

```markdown
# Daily Goal

**Current (2026-08-12):** <today's goal>

**Previous (2026-08-11):** <previous goal>
```

Replace only the content of the `# Daily Goal` section — do not touch other sections. On the first run, also migrate any pre-existing untagged text in that section into `goals.md` as the previous day's entry if the user can confirm which day it was for; otherwise just show it as **Previous** without a date.

## 5. Add a TODO item (only if text was provided)

The item text is whatever the user typed after the trigger (e.g. `/standup-todo <item text>` → item is `<item text>`).

- Use the trailing text verbatim as the item. Do not rephrase, expand, or "improve" it.
- If no text was provided, skip this step — the goal/prune steps above are still a valid invocation on their own.

Locate the `# Today` heading in `standup.md`. If there is no `# Today` heading, STOP and ask the user where to add the item rather than guessing.

Insert the new item as the first entry under `# Today`, immediately after the heading, pushing existing content down. Match the file's existing spacing: a blank line, then the item, then a blank line.

Use `Edit` with the `# Today` heading and the text right after it as the anchor so the insert is precise and existing notes are never clobbered. The inserted line format is:

```
- [ ] <item text>
```

## 6. Confirm

Summarize what happened this invocation: the previous goal, today's goal (and whether it was just set or already existed), any pruned done items, and the TODO added (echo its text verbatim). Do not touch any other section, and do not commit or stage anything — notes only.
