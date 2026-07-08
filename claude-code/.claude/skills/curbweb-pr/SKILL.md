---
name: curbweb-pr
description: Create a draft GitHub PR for a Curbwaste repo. Extracts the Jira ticket from the branch name, fills the repo's PR template (JIRA link, Summary with a concise blurb + bullet list of meaningful changes, and a Test Plan sourced from ~/notes or a canned default), then opens a draft PR with `gh`. Use when the user says "create a PR", "open a draft PR", "curbweb pr", or "/curbweb-pr".
allowed-tools: Bash, Read, Glob, Grep, Write
---

Create a draft GitHub PR for the current Curbwaste repository. Run every git/gh command from inside the target repo (use `git -C <repo>` or `cd` there first). Do not push or open the PR until the confirmation steps below are satisfied.

## 1. Establish context

Run these in the current repo:

- Current branch: `git branch --show-current`
- Repo root: `git rev-parse --show-toplevel`
- Base/default branch: `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/` — usually `master`). If it errors, fall back to `master`.

If the working directory is not a git repo, tell the user to run the skill from inside the target repo (e.g. `~/projects/curbwaste-web`) and stop.

## 2. Extract the Jira ticket

From the branch name, match the first `[a-z]+-[0-9]+` segment. This deliberately skips the type prefix — for `feat-pc-3565-dispatch-no-drivers-typeerror` the match is `pc-3565` (the `feat` prefix has no digits after it).

- Ticket key: uppercase the match → `PC-3565`.
- Jira URL: `https://curbwaste.atlassian.net/browse/PC-3565`.

If no match is found, ask the user for the ticket key rather than guessing.

## 3. Load the PR template

Read `<repo-root>/.github/PULL_REQUEST_TEMPLATE.md`. All Curbwaste repos currently use the same three-section template:

```
### JIRA Ticket
Link to JIRA ticket.

### Summary
Provide an itemized list of the changes you made in this pull request.

### Test Plan
Include the testing steps used to verify the changes, written in the past tense.
```

Use the template you actually read (do not hardcode it) so section names/order stay correct if a repo diverges.

## 4. Fill the JIRA Ticket section

Replace the placeholder line `Link to JIRA ticket.` with a markdown link:

```
[PC-3565](https://curbwaste.atlassian.net/browse/PC-3565)
```

## 5. Draft the Summary — then pause for edits

Look at what actually changed: `git diff <base>...HEAD --stat` and `git diff <base>...HEAD` (read the diff, not just names). Then write:

- A **concise summary of no more than four sentences** describing what the PR does and why.
- A **bullet list of the meaningful changes**. Keep it focused, not exhaustive. Do **not** list test changes, formatting/lint churn, or trivial mechanical edits.

Present the drafted summary + bullets to the user and **stop for their review/edits** before assembling the rest of the body. Incorporate any changes they make.

## 6. Fill the Test Plan section

Check `~/notes` for a testing note tied to the ticket (glob `~/notes/*PC-3565*`, and search note contents for the ticket key or the branch's feature area). Then ask the user which they want:

1. **A specific plan based on the testing notes** — if a relevant note exists, offer to build the Test Plan steps from it (written in past tense).
2. **The canned default:**
   ```
   * Ran associated unit tests.

   * Ran associated E2e tests.
   ```

Use whichever the user picks. If no testing note exists, still offer the canned default.

## 7. Compose the PR title

Derive from the branch name (no network call):

- Drop the leading type prefix (`feat`, `fix`, `chore`, `refactor`, etc.) and the ticket segment.
- Replace hyphens with spaces and sentence-case the result.
- Prefix with the ticket key.

Example: `feat-pc-3565-dispatch-no-drivers-typeerror` → `PC-3565: Dispatch no drivers typeerror`.

## 8. Confirm the full body, then push + create

1. Write the assembled body to a temp file (e.g. `/tmp/curbweb-pr-body.md`).
2. Show the user the final **title** and **body** for approval.
3. Check whether the branch is on origin: `git ls-remote --heads origin <branch>`. If it is **not** pushed, **ask the user before** running `git push -u origin <branch>`.
4. Create the draft PR:
   ```
   gh pr create --draft --base <base> --title "<title>" --body-file /tmp/curbweb-pr-body.md
   ```
5. Report the PR URL that `gh` returns.

## Notes

- Never open the PR or push without the confirmations in steps 5 and 8.
- Keep the Summary tight — four sentences max, meaningful bullets only.
- If `gh` reports a PR already exists for the branch, surface that instead of forcing a new one.
