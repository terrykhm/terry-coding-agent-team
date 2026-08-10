# Engineering Agent Conventions

These conventions are shared by four cooperating skills: **backlog-coder**, **pr-reviewer**, **backlog-critic**, and **eng-secretary**. They define the formats each agent reads and writes so the agents can hand work to each other (and to humans) without ambiguity.

**Repo overrides win.** If the repo contains its own conventions — an `AGENTS.md`, `CONTRIBUTING.md`, a `backlog/README.md`, or an existing backlog in a different format — follow the repo's conventions instead of the defaults below. These defaults exist so agents can bootstrap a repo that has nothing yet.

---

## Backlog format

The backlog lives in the repo as markdown. Default layout:

```
BACKLOG.md            # the backlog itself (single file is fine for most repos)
MILESTONES.md         # optional: milestone definitions and target dates
```

Each task is a `##` section in `BACKLOG.md`:

```markdown
## T-014: Add rate limiting to public API

- **Status:** todo
- **Priority:** high
- **Milestone:** v1.2
- **PR:** (none yet)
- **Blocked-by:** (none)

Public endpoints currently have no rate limiting; a single client can
saturate the service.

**Acceptance criteria:**
- [ ] Requests beyond N/min per API key receive HTTP 429 with Retry-After
- [ ] Limits configurable via env var
- [ ] Existing integration tests still pass; new tests cover the 429 path
```

Rules:
- **Task IDs** are `T-` followed by a zero-padded number (`T-001`, `T-014`). IDs are never reused or renumbered — other artifacts (branches, PRs, review comments) refer to them.
- **Status** is one of: `todo`, `in-progress`, `in-review`, `blocked`, `done`. Whoever changes the real-world state updates the status field in the same change (e.g., backlog-coder sets `in-review` and fills in the PR link in the PR branch itself when it opens the PR).
- **Blocked-by** lists the T-### IDs of tasks that must reach `done` before this task can start (e.g., `T-011, T-012`). Use `(none)` when there are no dependencies. A task with a non-empty `Blocked-by` whose dependencies are not all `done` must carry `Status: blocked` — this is called a **blocked-by-design** task: it is blocked intentionally by sequencing, not by an external issue. Agents filter these out when selecting work; they are distinct from tasks that are `blocked` for external reasons (in which case `Blocked-by` is `(none)` and the blocking reason is described in the task body).
- **Acceptance criteria** are checkboxes. They are the definition of done — the coder implements against them, and the reviewer verifies against them.
- New tasks get the next unused ID. If tasks grow numerous, they may be split into `backlog/T-###-slug.md` files with the same section format; `BACKLOG.md` then becomes an index.

## Branches and commits

- Branch name: `task/T-014-rate-limiting` (task ID + short slug).
- Commit messages: conventional-commit style (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`), body references the task ID.
- One task per branch/PR. If a task is too big for one PR, that is a backlog problem — split the task first.

## PR description template

Every agent-opened PR uses this structure so the reviewer and secretary can parse it:

```markdown
## Task
T-014: Add rate limiting to public API

## Approach
2-6 sentences: what was done and why this approach over alternatives.

## Changes
- Bullet list of notable changes, by area.

## Testing
What was run and what it showed. Include commands and relevant output.

## Notes for reviewer
Tradeoffs made, areas of uncertainty, anything needing extra scrutiny.
```

## Review format

Reviews (from pr-reviewer or humans) use numbered findings so revisions can reference them precisely:

```markdown
## Review of PR #NN (T-014)

**Verdict: REQUEST_CHANGES**   <!-- or: APPROVE_WORTHY -->

### Findings
- **[R1] (blocking)** The limiter counts per-IP, but the acceptance
  criteria specify per-API-key. `middleware/ratelimit.go:41`
- **[R2] (blocking)** No test covers the Retry-After header value.
- **[R3] (suggestion)** Consider extracting the window math into a
  helper for readability.

### What's good
Brief note of what works well — reviewers who only list flaws train
coders to hide uncertainty.
```

Rules:
- Finding IDs are `[R1]`, `[R2]`, … scoped to that review. A second review round starts at the next number (`[R4]`…), never reusing IDs.
- Severity is `blocking` (must fix before merge) or `suggestion` (author's discretion).
- Verdict is exactly `REQUEST_CHANGES` or `APPROVE_WORTHY`. The agent never merges and never formally approves — `APPROVE_WORTHY` signals to the human "I found nothing blocking"; the human makes the call.

## Revision responses

When backlog-coder revises a PR, it replies to the review (as a PR comment) mapping every finding to an action:

```markdown
## Revisions for review of PR #NN

- **[R1]** Fixed — keying on API key now; see commit `a1b2c3d`.
- **[R2]** Fixed — added test `TestRetryAfterHeader` in commit `a1b2c3d`.
- **[R3]** Not taken — the helper would be used once; left inline.
```

Every finding gets a line: `Fixed`, `Not taken` (with reasoning), or `Question` (when the finding is unclear — better to ask than guess).

## GitHub interaction

- Use the `gh` CLI (`gh pr create`, `gh pr view`, `gh pr diff`, `gh pr comment`, `gh api`) for all GitHub operations.
- If `gh` is unavailable or unauthenticated, do not fail the task: produce the artifact (PR description, review, comment) as a markdown file in the working directory and tell the user exactly what to post and where.
- Never merge PRs, never dismiss reviews, never force-push over someone else's commits.
