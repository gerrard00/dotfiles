---
name: qa-summary
description: Generate a QA summary for a Curbwaste Jira story or QA defect, written for a tester rather than a reviewer. Given a ticket (or the current git branch), finds the linked dev tasks, pulls their PRs from the Jira dev panel, scans the PR diffs for LaunchDarkly feature flags, and outputs what changed in the tester's terms, how to test it, the required state of every feature flag and company setting, PR links, and captioned screenshot placeholders. Deliberately contains no code detail. Use when the user says "give me a QA summary", "give me a QA summary for PC-XXXX", or "/qa-summary".
allowed-tools: Bash, Read, Grep, Glob, mcp__claude_ai_Atlassian_Rovo__getJiraIssue, mcp__claude_ai_Atlassian_Rovo__getTeamworkGraphContext, mcp__claude_ai_Atlassian_Rovo__getTeamworkGraphObject
---

Generate a QA summary for a Curbwaste Jira **story** or **QA defect**. The output has five sections:

1. **What changed** — what the product does differently now, described entirely in the tester's terms.
2. **How to test** — the steps that reach the changed behavior, and what should be observed.
3. **Gate state required** — the feature flags and company settings, each with the state it must be in.
4. **PRs** — a bullet list of markdown links.
5. **Screenshots** — captioned slots, filled with the images through the browser.

Follow the steps below in order. Do not fabricate flags, PRs, or change descriptions — every item must be grounded in the Jira links and PR diffs you actually retrieve.

## Who this is for

**The reader is a tester, not a reviewer. They do not need to know anything about the code, and telling them is actively unhelpful: it buries the behavior they have to verify.**

Never write, in any section:

- file, function, class, table, column, endpoint, query or repository names
- layer or architecture language: "read side", "the cascade", "the join", "the filter", "server side", "the payload", "the response"
- what the old code did wrong in implementation terms

Write what a person sees on a screen, and what they should see now. If a sentence would not make sense to someone who has never opened the codebase, rewrite it. The one exception is flag keys, which the tester copies into LaunchDarkly verbatim.

## Fixed context

- **Jira:** site host and cloudId are not stored in this repo. Resolve them per "Resolve the Jira site" below.
- **GitHub org:** `curbsidetechnologies`.
- **Backend repo:** `~/projects/curbwaste-backend` (GitHub `curbsidetechnologies/curbwaste-backend`).
  - Feature-flag enum: `src/launch-darkly/constants.ts` → `enum LaunchDarklyFeatureFlag { MEMBER = 'ld_key', ... }`. Code references flags as `FeatureFlag.MEMBER` or `LaunchDarklyFeatureFlag.MEMBER`.
- **Web repo:** `~/projects/curbwaste-web` (GitHub `curbsidetechnologies/curbwaste-web`).
  - Feature-flag keys are kebab-case string literals registered in `src/App/hooks/useFeatureFlags.ts` (e.g. `'onboarding-automation'`). These strings ARE the LaunchDarkly keys.

## 0. Resolve the Jira site (cached daily)

The Jira host and cloudId are not stored in this repo. Resolve them at runtime and cache them for the day.

**Cache file:** `${TMPDIR:-/tmp}/claude-jira-site.json`, shaped:

```json
{
  "resolved_on": "YYYY-MM-DD",
  "site_url": "<https://your-site.atlassian.net>",
  "cloud_id": "<cloudId>"
}
```

Read it with `Read` (or `cat` via Bash). Use the cached values **only** when `resolved_on` equals today's
date. A missing file, unparseable JSON, a missing key, or a stale `resolved_on` is **not an error** — it
just means resolving again. Never fail the skill because of the cache.

To resolve, call `mcp__claude_ai_Atlassian__getAccessibleAtlassianResources` and take the single accessible
site. If more than one comes back, ask which site is meant rather than guessing. Then rewrite the whole
cache file with `Write`, stamping `resolved_on` with today's date.

Referred to below as **the Jira site URL** and **the cloudId (resolved above)**. Build ticket links as
`<site URL>/browse/<KEY>`.

## 1. Resolve the story ticket key

- If the user supplied a key (e.g. "QA summary for PC-123"), use it. Match `[A-Za-z]+-\d+`, uppercase it.
- If no key was supplied ("give me a QA summary"), derive it from the git branch — same logic as the `notes` skill:
  - Run `git branch --show-current`.
  - Extract the **first** Jira-style key with regex `[A-Za-z]+-\d+` (case-insensitive), uppercase it. Example: `feat-pc-123-some-feature-name` → `PC-123`.
  - If not in a git repo or no key is found, STOP and ask the user for the ticket key. Do not guess.

## 2. Get the story and its linked dev tasks

Call `getJiraIssue` with `cloudId`, `issueIdOrKey = <KEY>`, and `fields: ["summary", "issuelinks", "issuetype", "status"]`.

- **Dev tasks** = the issues in `issuelinks` on the implementation side of the link. In this project the relationship is usually the "Polaris work item link" type (`implements` / `is implemented by`); the story is "implemented by" its dev tasks. Collect the linked issue keys.
  - If the link type is ambiguous, include every linked issue that is a `Task`, `Bugs`, or `Sub-task` (the bug type is named `Bugs`, plural).
- Also keep the **story key itself** in the set of issues to check for PRs — work is sometimes linked directly to the story.
- If there are no linked dev tasks, tell the user and proceed using just the story key.

## 3. Get the PRs for each issue (story + dev tasks)

The Jira dev panel is exposed through the Teamwork Graph, not through remote links. For **each** issue key from step 2:

1. Call `getTeamworkGraphContext` with:
   - `cloudId`, `objectType: "JiraWorkItem"`, `objectIdentifier: <issue key>`,
   - `detailLevel: "full"`, `targetObjectTypes: ["ExternalPullRequest"]`.
2. Collect the returned `ExternalPullRequest` ARIs.

Then batch-hydrate the ARIs (up to 25 per call) with `getTeamworkGraphObject` (`cloudId` + `objects: [ari, ...]`). From each hydrated object read:
- `raw.url` — the GitHub PR URL.
- `raw.title` (or `displayName`) — the PR title.
- `raw.pullRequestStatus` — one of `OPEN`, `MERGED`, `DECLINED`.

Dedupe PRs by URL (the same PR can be linked to multiple issues).

## 3a. Check the ticket is actually ready

If **any** PR from step 3 has status `OPEN`, stop and tell the user the ticket is not ready for QA, naming which PRs are outstanding. Offer to draft the summary and hold it. Do not emit a summary that lists or hedges about unmerged work, and do not transition the ticket.

## 4. Scan PR diffs for feature flags

For each PR (all statuses — flags in open PRs are still relevant to the story), fetch the diff and detect flags. Derive `<repo>` and `<num>` from the PR URL (`https://github.com/curbsidetechnologies/<repo>/pull/<num>`):

```
gh pr diff <num> -R curbsidetechnologies/<repo>
```

Detect flags by repo:

- **curbwaste-backend:** find enum-member references in the diff with `FeatureFlag\.([A-Z0-9_]+)` and `LaunchDarklyFeatureFlag\.([A-Z0-9_]+)`. For each unique member, look up its LaunchDarkly key (the string value) in `~/projects/curbwaste-backend/src/launch-darkly/constants.ts`. Report the **string value** (e.g. `IS_ROUTING_LABEL_ENABLED` → `is_routing_label_enabled`).
- **curbwaste-web:** build the set of known flag keys from `~/projects/curbwaste-web/src/App/hooks/useFeatureFlags.ts` (the kebab-case string literals). Report any of those keys that appear in the diff. These strings are already the LaunchDarkly keys.
- **Other repos** (e.g. driver app): scan the diff for kebab-case or `is_*_enabled` string literals that look like LD keys, but only report them if you are confident they are feature flags; otherwise omit.

Only count a flag when it actually appears in a diff for one of this story's PRs. Deduplicate the flag list across all PRs.

## 5. Derive "what changed" and "how to test"

You read the diffs to know what the change is. You then describe it without any of what you read. Ground both sections in the ticket's own reported behavior, the story summary, and what the diffs prove, and write them per "Who this is for" above.

**What changed.** Lead with the situation the user is in, then what used to happen, then what happens now. A useful shape: *"When a hauler terminates a service and the removal is completed, an outstanding pickup could still be owed. That work used to disappear from the operator's worklist. It now stays there until it is actually done."* If the ticket covers more than one surface or symptom, number them so the tester can check each.

**How to test.** The steps that reach the behavior, in the order a tester performs them, ending with what they should observe. Reuse the ticket's own reproduction steps where it has them, since that is what they will follow anyway. Add the negative case when one exists: the condition under which the old behavior is still correct.

**Anticipate the false defect.** If the change leaves something on screen that looks wrong but is not, say so plainly in its own short section. Two numbers that have never matched, a row that correctly disappears, an item deliberately left alone. This is what stops a re-filed ticket.

**Say what is out of scope.** If part of the reported symptom was ruled pre-existing or is fixed elsewhere, state it and say a separate ticket may follow. A tester who re-fails the whole ticket over an unfixed half costs a full cycle.

If the diffs don't make the behavior change clear, keep it to what the ticket and PR titles support; do not invent specifics.

## 6. Emit the output

Sections in this order: **What changed**, **How to test**, any false-defect or scope note, **Gate state required**, **PRs**, **Screenshots**.

```
## What changed

When a hauler terminates a service and the asset removal is completed, an on call pickup can still be outstanding, so the crew still owes that customer a visit. That chain used to disappear from the operator's worklist. It now stays there until the outstanding work is actually done, and drops off once nothing is left.

## How to test

1. Create an on call delivery and schedule an on call pickup.
2. Terminate the order with an asset removal and a future service end date.
3. Complete the removal through dispatch.
4. Open Orders, Routing, Live. The chain should still be listed, carrying the outstanding pickup.
5. Complete the pickup as well. The chain should now drop off the Live tab.

## Gate state required

- Feature flag `is_delivery_removal_enhancements_enabled` (LaunchDarkly, per company): **ON**
- Company setting *Portalet Delivery and Removal Flexibility*: **ON**
- Company setting *Provide completion status out of sequence*: **not required, either state**

## PRs

- [fix: PC-123 some feature name](<PR URL>)

## Screenshots

1. Before: the chain is absent from the list.

*[screenshot 1 here]*

2. After: the chain is listed with its outstanding work.

*[screenshot 2 here]*
```

### Gate state

Name **every** gate a tester might reasonably wonder about, each with the state it must be in, including the ones that do not matter. "Not required, either state" is information; omitting the line leaves them guessing.

For work on the delivery and removal epic that is the LaunchDarkly flag plus **both** company settings, *Portalet Delivery and Removal Flexibility* and *Provide completion status out of sequence*.

If the change ships ungated, say so outright rather than dropping the section:

```
- **No feature flag.** This ships plain, ungated. There is nothing to switch on.
```

### PRs

**List merged PRs only. Never mention an unmerged PR, not even to say it is unmerged.**

A QA summary is written for a ticket that is ready to test, and a ticket is only ready to test once every PR has merged, because alpha carries merged code. Naming an open PR either advertises that the ticket is not actually ready, or invites a tester to test against code that is not deployed. Neither helps them.

If some of the ticket's PRs are still open, the summary is premature. Say so to the user and stop:

> N of this ticket's PRs are still open, so it is not ready for QA. I can write the summary now and hold it until they merge.

The summary can be drafted and the evidence gathered at any time. It is posting it, and the transition that goes with it, that waits.

### Screenshots

Give every slot a caption saying what it demonstrates, then an empty placeholder on its own line. Number them so pasting in order is unambiguous.

Pick only shots that demonstrate the fixed behavior. Pre-fix reproduction captures belong in the ticket notes, not here, unless they are the before half of an explicit before and after pair.

🛑 **Get the text completely right before any image goes in.** Once images are in the comment, editing it through the API destroys them: the API returns them as `blob:` references that do not survive a round trip, and the surrounding captions are dropped with them. While the comment still holds nothing but text and empty slots, API edits are safe and are the right way to fix wording. After the images are in, make further changes through the browser editor, or post a second comment.

#### Inserting the images yourself, through the browser

The images do not have to be pasted by hand. Drive Chrome through the chrome-devtools MCP and
fill every slot, in one pass, before handing the ticket back.

The two obvious routes both fail, so do not spend time on them:

- `Meta+v` dispatched over CDP does not paste. It is a synthetic key event and Chrome never reads
  the real system clipboard, so the `copy-image-to-clipboard` route can only be driven by the user
  at the keyboard.
- The editor toolbar's **Add image, video, or file** button does not open an interceptable file
  chooser. `upload_file` against it fails with "clicking it did not trigger a file chooser".

What works is the editor's own hidden file input, `[data-testid="media-picker-file-input"]`. It
accepts files directly, but hidden elements carry no uid in the accessibility snapshot, so it has
to be made visible first.

1. **Stage the images under the working directory.** `upload_file` only accepts paths beneath it,
   and the images live in `~/notes/<KEY>/`. Copy them to a temp directory inside the working
   directory, renamed `slot-01-…` through `slot-NN-…` so slot order is unambiguous. Delete the
   directory when done.
2. **Open the comment for editing.** Snapshot the page, find the comment's **Edit** button, click
   it. The editor subtree appears with its own uid prefix; note the **Save** button's uid now, since
   later snapshots are large.
3. **Expose the file input.** There are usually two matches for
   `[data-testid="media-picker-file-input"]`. Pick the one whose ancestors include
   `[data-testid="editor-content-container"]` — the other belongs to the page, not the comment
   editor. Note that `editor-content-container` is a **data-testid, not an id**: selecting it as
   `#editor-content-container` matches nothing, and a fallback to the first match then grabs the
   page input, whose uploads never reach the comment. Give it an
   `aria-label` and a fixed position with real width and height. Do not test the result with
   `offsetParent`, which is null for fixed elements; check `getBoundingClientRect()`. Snapshot and
   grep for the label to get its uid. That uid stays valid for the whole pass.
4. **Fill the slots in descending order, N down to 1.** Working backwards means each insertion
   lands below every marker still to be filled, so no earlier marker shifts under you. For each:
   - Select the marker's text node with a DOM `Range` plus `window.getSelection()` (ProseMirror
     picks the selection up from the DOM), and scroll it into view.
   - `press_key` **Backspace** to delete the marker, leaving an empty paragraph holding the caret.
   - `upload_file` the slot's image against the exposed input's uid. The media lands in that
     paragraph.
5. **Verify before saving.** Walk the editor's children and confirm no `[screenshot N here]` text
   remains and that captions and images alternate in the right order. Then click **Save**.
6. **Verify after saving** by re-reading the comment through `getJiraIssue` with
   `responseContentFormat: "adf"`. Check there is one `mediaSingle` per slot, each after its own
   caption, and that each `alt` matches the file intended for that slot.

Two things that cost a pass if you hit them:

- **Never press Escape in the editor.** It closes the comment editor outright and discards the
  edit, rather than dismissing whatever stray popup prompted it. Jira keeps a local draft, the
  comment's button then reads **Edit (Unsaved changes)**, and reopening restores that draft. Any
  slot whose marker was already deleted comes back as an empty paragraph with no marker text to
  select, so fill it by placing a collapsed `Range` in the paragraph after its caption instead.
- **The upload is not finished when `upload_file` returns.** Confirm the media landed before
  moving on, by counting `.media-card-wrapper` inside the editor after each slot.

Only when the browser is unavailable does the manual route apply: offer to put the images on the
clipboard one at a time with the `copy-image-to-clipboard` skill, naming which numbered slot each
belongs to.

## Notes

- **The audience test, before you post:** would every sentence make sense to someone who has never seen the codebase? Anything that fails it is either rewritten in behavior terms or cut. Code detail belongs in the PR description, which has a different reader.
- Keep flag keys exact and unexplained — the user relies on copy-pasting them into LaunchDarkly.
- If `gh` is not authenticated (`gh auth status` fails), tell the user to authenticate rather than silently skipping diffs.
- Local repos may be on an older commit than the PR; `gh pr diff` fetches the diff from GitHub, so no local checkout is required. The constants/hook lookups (steps for mapping flag keys) read the local repo — if a referenced enum member isn't found locally, report the enum-member name and note it couldn't be mapped to an LD key.
