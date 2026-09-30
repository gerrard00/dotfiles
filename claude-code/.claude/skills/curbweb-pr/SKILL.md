---
name: curbweb-pr
description: Create a draft GitHub PR for a Curbwaste repo. Extracts the Jira ticket from the branch name, fills the repo's PR template (JIRA link, Summary with a concise blurb + bullet list of meaningful changes, a Test Plan sourced from ~/notes or a canned default, and a Screenshots section with placement comments when ~/notes has screenshots for the ticket), then checks that every behavioral change is behind a LaunchDarkly feature flag and stops for confirmation if any is not, before opening a draft PR with `gh`. Use when the user says "create a PR", "open a draft PR", "curbweb pr", or "/curbweb-pr".
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

From the branch name, match the first `[a-z]+-[0-9]+` segment. This deliberately skips the type prefix — for `feat-pc-123-some-feature-name` the match is `pc-123` (the `feat` prefix has no digits after it).

- Ticket key: uppercase the match → `PC-123`.
- Jira URL: `https://curbwaste.atlassian.net/browse/PC-123`.

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
[PC-123](https://curbwaste.atlassian.net/browse/PC-123)
```

The body must contain a URL literally matching `https://curbwaste.atlassian.net/browse/[A-Z]+-\d+` (the markdown link above satisfies this) or the PR check fails.

## 5. Draft the Summary — then pause for edits

Look at what actually changed: `git diff <base>...HEAD --stat` and `git diff <base>...HEAD` (read the diff, not just names). Then write:

- A **concise summary of no more than four sentences** describing what the PR does and why. It must contain **at least 5 words** (the PR check fails otherwise).
- A **bullet list of the meaningful changes**. Keep it focused, not exhaustive. Do **not** list test changes, formatting/lint churn, or trivial mechanical edits.

At the same time, discover screenshots for the ticket and draft the Screenshots section (see step 7). Present the drafted summary + bullets **and** the drafted screenshot list (titles, in order) to the user and **stop for their review/edits** before assembling the rest of the body. Incorporate any changes they make — including dropping screenshots that don't belong in the PR (e.g. debugging evidence) or renaming titles.

## 6. Fill the Test Plan section

Check `~/notes` for a testing note tied to the ticket (glob `~/notes/*PC-123*`, and search note contents for the ticket key or the branch's feature area). Then ask the user which they want:

1. **A specific plan based on the testing notes** — if a relevant note exists, offer to build the Test Plan steps from it (written in past tense).
2. **The canned default:**
   ```
   * Ran associated unit tests.

   * Ran associated E2e tests.
   ```

Use whichever the user picks. The Test Plan must have **at least 2 bullet points** (the canned default has two) — the PR check fails otherwise. If no testing note exists, still offer the canned default.

## 7. Add a Screenshots section — only if screenshots exist

Screenshots for a ticket live in `~/notes` in one of two layouts. Check both (case-insensitive extensions `png`, `jpg`, `jpeg`, `gif`, `webp`):

1. Per-ticket directory: `~/notes/PC-123/*.png`
2. Flat files prefixed with the lowercase key: `~/notes/pc-123-*.png`

If **no** screenshots are found, skip this step entirely — the body keeps its three template sections and no Screenshots section is added.

If screenshots exist:

- **Order** them by numeric filename prefix when present (`02-orders.png` → 2); otherwise by file modification time, oldest first.
- **Title** each one by humanizing its filename: strip any numeric prefix, ticket-key prefix, and extension; hyphens → spaces; sentence-case the result. Example: `verify-modal-testdriver2-configured.png` → `Verify modal testdriver2 configured`.
- **Render** a `### Screenshots` section appended after the Test Plan section. Each screenshot gets a `####` title followed by an HTML comment with its order number and filename:

  ```markdown
  ### Screenshots

  #### Verify listing icons
  <!-- screenshot 1: verify-listing-icons.png -->

  #### Verify modal testdriver2 configured
  <!-- screenshot 2: verify-modal-testdriver2-configured.png -->
  ```

The comments mark where to paste each image in the GitHub UI after the PR is created (`gh` cannot upload local images into the body). The drafted list is presented for review during the step 5 pause; only screenshots the user kept make it into the body.

## 8. Compose the PR title — obey the repo's enforced format

Each repo enforces its own title format in `.github/workflows/pull-request-check.yaml` (the "Check PR title format" step). **Read that file first** and build a title that satisfies the `PATTERN` it defines — do not assume a fixed format.

Gather the pieces from the branch name (no network call):

- **type**: the leading branch prefix — `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, `style`, `revert`. Normalize to what the pattern allows: `feature` → `feat`; `bugfix`/`hotfix` → `fix` (unless the pattern lists `hotfix`/`feature` explicitly, in which case keep it).
- **ticket**: the uppercase key from step 2, e.g. `PC-123`.
- **subject**: the remaining branch words (hyphens → spaces), lowercase. Must be **at least 10 characters**; if the branch slug is too short, expand it using the drafted summary so it's descriptive.

Then match the repo's pattern. The ticket-prefix allowlist **differs per repo** — take it from the file you just read, not from the examples below.

- **Conventional style** — `curbwaste-web`, `curbwaste-backend`, `curbwaste-apis`. Pattern shape:
  `^(feat|fix|chore|docs|refactor|test|build|ci|perf|style|revert)(\([a-z0-9-]+\))?!?: (CW|PA|PB|PC|PP|CP|RCI|AI)-[0-9]+ .{10,}$`
  → `feat: PC-123 some feature name`
  (type first, colon-space, then `TICKET-### subject` — note the **space**, not a colon, between ticket and subject). The optional scope is a real lowercase-slug group, e.g. `feat(dispatch): PC-123 …`. `curbwaste-apis` and `curbwaste-backend` allow `AI`; `curbwaste-web` does **not**.

- **Bracketed style — legacy, weighworks only** (`weighworks.v2-backend`, `weighworks.v2-frontend`). Pattern:
  `^\[(hotfix|fix|feature|feat|chore)\] (CP)-[0-9]+ .{10,}$`
  → `[feat] CP-123 some feature name`. Note the allowlist is **`CP` only** here, and these workflows inline the regex in the `grep -qP` with no `PATTERN=` variable.

- **No title-check workflow** (`curbwaste-api-gateway`, `curbwaste-background-jobs`, `curbwaste-quickbooks-service`, `curbwaste.driver.app`, `curbwaste-mono`, `curbwaste-qa`): default to the conventional style above.

**`curbwaste-apis` used to be the bracketed example** — it moved to conventional in a shared commit and PR conventions change. Don't reintroduce `[feat]` for it. Repos migrate, which is why this step opens by telling you to read the workflow.

Verify the finished title against the repo's own regex before proceeding — the PR check fails otherwise. This extracts the pattern in either shape (a `PATTERN=` variable, or the regex inlined in the `grep -qP`) and matches with `perl`:

```bash
WF=<repo-root>/.github/workflows/pull-request-check.yaml
TITLE='feat: PC-123 some feature name'
PATTERN=$(sed -n "s/^ *PATTERN='\(.*\)'$/\1/p" "$WF")
[ -n "$PATTERN" ] || PATTERN=$(sed -n "s/.*grep -qP '\(.*\)'.*/\1/p" "$WF")
TITLE="$TITLE" PATTERN="$PATTERN" perl -e 'exit($ENV{TITLE} =~ /$ENV{PATTERN}/ ? 0 : 1)' \
  && echo OK || echo FAILS
```

Use `perl`, **not** `grep -P` — CI runs GNU grep on `ubuntu-latest`, but macOS ships BSD grep, which has no `-P` and errors with `invalid option -- P`. That failure looks like a rejected title. `grep -E` happens to work on both current patterns but would break on any PCRE-only construct added later.

## 9. Feature flag gate — nothing is pushed or created until this passes

All code should ship behind a LaunchDarkly feature flag so it can be killed if it fails. This step runs **before** the push and before `gh pr create`. It is not advisory: if any behavioral change in the diff is not flag-gated, stop and do not push, do not create the PR, and do not tell the user the PR is OK to mark ready for review.

Audit `git diff <base>...HEAD`:

- Identify every new or changed **behavioral** code path. Ignore tests, type-only changes, formatting and lint churn, comments, and dependency bumps.
- For each, determine whether it is reachable only when a flag is on. The flag key literal must be checked at the site itself (or in the immediately enclosing guard) — a derived boolean, a wrapper helper, or a flag checked in some other module does not count as verified unless you actually read that code and confirmed the gating.
- Name the flag key(s) found, and list every path that executes regardless of flag state.

Report the result as an explicit list: each unflagged path with its `file:line` and one line on what it does when the flag is off.

If **everything** is gated, say so, name the flag key(s), and continue to step 10.

If **anything** is ungated, present the list and ask the user, in this run, whether the missing flag is acceptable. Wait for their answer.

- A confirmation is valid **only for this run**. Never carry one forward — not from earlier in the session, not from a previous PR on the same branch, not from a note, not from the ticket, not from a general policy the user stated before. If the check runs again, ask again, even if they just approved the same path a minute ago.
- Do not pre-judge the answer or argue the case for proceeding. Report what is ungated and ask.
- If the user does not clearly confirm, stop. Leave the branch unpushed and no PR created.

## 10. Confirm the full body, then push + create

1. Write the assembled body to a temp file (e.g. `/tmp/curbweb-pr-body.md`).
2. Show the user the final **title** and **body** for approval.
3. Check whether the branch is on origin: `git ls-remote --heads origin <branch>`. If it is **not** pushed, **ask the user before** running `git push -u origin <branch>`.
4. Create the draft PR:
   ```
   gh pr create --draft --base <base> --title "<title>" --body-file /tmp/curbweb-pr-body.md
   ```
5. Report the PR URL that `gh` returns.

## Notes

- Never open the PR or push without the confirmations in steps 5, 9 and 10.
- The step 9 feature flag gate is never skipped and never satisfied by a past confirmation.
- Keep the Summary tight — four sentences max, meaningful bullets only.
- If `gh` reports a PR already exists for the branch, surface that instead of forcing a new one.
