---
description: Check local notes in ~/notes for a Jira ticket, technology, topic, filename, or general notes review before answering. Use when the user says "check my notes", "check for my notes", "check my notes on X", or references notes like PC-123, postgres, or another note key.
allowed-tools: Read, Bash
---

Identify whether the user requested:

1. A specific note key or topic, such as:
   - `PC-123`
   - `postgres`
   - `billing`
   - `customer imports`

2. A general notes review, such as:
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

Use commands like:

```bash
test -f ~/notes/<query>.md && echo ~/notes/<query>.md
find ~/notes -maxdepth 1 -type f -iname "*<query>*"
rg -i "<query>" ~/notes
```

Read the most relevant matching note or notes.

## General notes review

If the user says only "check my notes" or asks for notes in general, inspect recent and relevant notes under `~/notes`.

Start with recently modified markdown files:

```bash
find ~/notes -maxdepth 1 -type f -name "*.md" -printf "%T@ %p\n" | sort -nr | head -20
```

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
