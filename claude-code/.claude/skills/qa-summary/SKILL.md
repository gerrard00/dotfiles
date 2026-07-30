---
name: qa-summary
description: Generate a QA summary for a Curbwaste Jira story. Given a story ticket (or the current git branch), finds the linked dev tasks, pulls their PRs from the Jira dev panel, scans the PR diffs for LaunchDarkly feature flags, and outputs a plain-language "what changed" summary, a bullet list of feature flags, a bullet list of markdown links to the (non-open) PRs, and a screenshots placeholder. Use when the user says "give me a QA summary", "give me a QA summary for PC-XXXX", or "/qa-summary".
allowed-tools: Bash, Read, Grep, Glob, mcp__claude_ai_Atlassian_Rovo__getJiraIssue, mcp__claude_ai_Atlassian_Rovo__getTeamworkGraphContext, mcp__claude_ai_Atlassian_Rovo__getTeamworkGraphObject
---

Generate a QA summary for a Curbwaste Jira **story**. The output has four sections:

1. **What changed** — a short plain-language description of the behavior change, in domain terms.
2. A bullet list of the LaunchDarkly feature flags relevant to the story (flag keys only, no explanations).
3. A bullet list of the PRs for all related dev tasks, each entry a markdown link to the PR.
4. **Screenshots** — a placeholder for the user to attach images manually.

Follow the steps below in order. Do not fabricate flags, PRs, or change descriptions — every item must be grounded in the Jira links and PR diffs you actually retrieve.

## Fixed context

- **Jira:** `curbwaste.atlassian.net`, cloudId `da2b9a17-3135-436c-98ba-77e2089b46e8`.
- **GitHub org:** `curbsidetechnologies`.
- **Backend repo:** `~/projects/curbwaste-backend` (GitHub `curbsidetechnologies/curbwaste-backend`).
  - Feature-flag enum: `src/launch-darkly/constants.ts` → `enum LaunchDarklyFeatureFlag { MEMBER = 'ld_key', ... }`. Code references flags as `FeatureFlag.MEMBER` or `LaunchDarklyFeatureFlag.MEMBER`.
- **Web repo:** `~/projects/curbwaste-web` (GitHub `curbsidetechnologies/curbwaste-web`).
  - Feature-flag keys are kebab-case string literals registered in `src/App/hooks/useFeatureFlags.ts` (e.g. `'onboarding-automation'`). These strings ARE the LaunchDarkly keys.

## 1. Resolve the story ticket key

- If the user supplied a key (e.g. "QA summary for PC-3168"), use it. Match `[A-Za-z]+-\d+`, uppercase it.
- If no key was supplied ("give me a QA summary"), derive it from the git branch — same logic as the `notes` skill:
  - Run `git branch --show-current`.
  - Extract the **first** Jira-style key with regex `[A-Za-z]+-\d+` (case-insensitive), uppercase it. Example: `feat-pc-3382-expose-termination-effective-date` → `PC-3382`.
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

## 5. Derive the "what changed" summary

Write a short (1-3 sentence) plain-language description of the behavior change, grounded in the story summary and the PR titles/diffs you retrieved. Rules:

- Describe behavior in **domain terms** — no filenames, class/method/symbol names, or other code identifiers.
- State the user-visible effect (what was broken, what it does now), not the implementation.
- If the diffs don't make the behavior change clear, keep it to what the story summary and PR titles support; do not invent specifics.

## 6. Emit the output

Print the four sections in this order: **What changed**, **Feature Flags**, **Pull Requests**, **Screenshots**. Use LaunchDarkly keys for the flags — no explanations, no extra columns.

```
## What changed

Fixed how a quantity or delivery-date change on a setup order syncs to its delivery order. The delivery order now updates reliably in both directions instead of intermittently keeping stale values.

## Feature Flags

- is_routing_label_enabled
- is_multiple_services_routing_enabled

## Pull Requests

- [feat: PC-3446 Itinerary Creation Endpoint](https://github.com/curbsidetechnologies/curbwaste-backend/pull/2620)
- [PC-3447 Frontend — Edit start/end on dispatch driver card](https://github.com/curbsidetechnologies/curbwaste-web/pull/XXXX)

## Screenshots

- _(add screenshots here)_
```

Rules for the output:

- **Exclude PRs whose status is `OPEN`** from the Pull Requests list. Merged and declined PRs are included.
- If any PRs were excluded because they are still open, add a short notice **after** the two sections so QA is aware, e.g.:

  ```
  > ⚠️ 2 open PR(s) not yet merged (excluded from the list above):
  > - [title](url)
  > - [title](url)
  ```

- If no feature flags were found, print `- _none_` (or state "No feature flags found in the PR diffs.") under the Feature Flags heading rather than omitting the section.
- If no non-open PRs were found, say so under the Pull Requests heading.
- Always include the Screenshots section with the `- _(add screenshots here)_` placeholder — the user attaches images manually.

## Notes

- Keep the flag section strictly to flag keys — the user relies on copy-pasting them into LaunchDarkly.
- If `gh` is not authenticated (`gh auth status` fails), tell the user to authenticate rather than silently skipping diffs.
- Local repos may be on an older commit than the PR; `gh pr diff` fetches the diff from GitHub, so no local checkout is required. The constants/hook lookups (steps for mapping flag keys) read the local repo — if a referenced enum member isn't found locally, report the enum-member name and note it couldn't be mapped to an LD key.
