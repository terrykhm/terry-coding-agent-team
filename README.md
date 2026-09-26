# terry-coding-agent-team

Personal Claude Code agents and skills, versioned so I can share the same setup across projects and machines.

Built around a **markdown-backlog + PR workflow** — expects a `BACKLOG.md` in the target repo and uses `gh` for PR operations.

---

## Agents

| Agent | Role | Stance |
|---|---|---|
| **team-lead** | Orchestrates all other agents; the entry point for the full workflow | Coordinator |
| **coder** | Implements backlog tasks, opens PRs, addresses review feedback | Boring engineer |
| **verifier** | Runs tests, exercises the feature, checks acceptance criteria before review | Skeptical witness |
| **reviewer** | Reviews PRs against acceptance criteria, returns [R#] findings + verdict | Adversarial skeptic |
| **critic** | Audits the backlog for gaps, risks, and bad sequencing; proposes tasks | Grounded pessimist |
| **planner** | Decomposes a product brief into sequenced, paste-ready backlog tasks | Delivery pragmatist |

Skills live in `skills/` and drive the same workflow via slash commands. `skills/shared/conventions.md` is the single source of truth for backlog, branch, PR, and review formats.

---

## Install

```sh
git clone git@github.com:terrykhm/terry-coding-agent-team.git ~/code/terry-coding-agent-team
cd ~/code/terry-coding-agent-team
./install.sh
```

Symlinks `agents/` and `skills/` into `~/.claude/`. Re-run after `git pull` to pick up changes.

```sh
./install.sh --uninstall   # removes only symlinks this repo created
```

---

## Usage

### Full workflow via team-lead

Start the team-lead from inside a tmux session (see tmux section below):

```sh
claude --agent team-lead
```

**Prompts to orchestrate the full team:**

```
# Work the backlog
Pick up the next available task and take it through the full workflow.

# Work a specific task
Pick up T-007 and take it through the full workflow.

# Plan a new feature before coding
Plan out user authentication — I want email/password login and JWT sessions.

# Audit the plan
Review the backlog for gaps and sequencing problems.

# Address review feedback
Human left comments on PR #14 — address them and push a revision.
```

The standard workflow the team-lead runs automatically:
**pick task → coder → verifier → reviewer → (revise loop, max 2 rounds) → report to human**

### Running agents individually

```sh
claude --agent coder        # implement a task or revise a PR
claude --agent verifier     # verify a PR before review
claude --agent reviewer     # review a PR
claude --agent critic       # audit the backlog
claude --agent planner      # plan a new feature into tasks
```

Or via skills (no team-lead, fires directly in your current session):

```
/backlog-coder    pick up T-012
/pr-reviewer      review PR #9
/backlog-critic   critique the v2 milestone
/planner          plan a settings page — per-user preferences, stored server-side
```

---

## tmux setup

Claude Code displays each running subagent as its own tmux window, so you can watch the coder, verifier, and reviewer working in parallel. **This only works when you start `claude` from inside an active tmux session.** If you launch `claude` outside tmux, agents still run but their real-time output is hidden.

### Start every session this way

```sh
tmux new -s work          # create a named session
claude --agent team-lead  # now agents will open as windows automatically
```

To resume an existing session:

```sh
tmux attach -t work
```

### Why agents sometimes don't appear as panes

| Situation | What happens |
|---|---|
| Started `claude` outside tmux | Agents run headlessly — no panes |
| Started `claude` inside tmux | Each agent gets its own tmux window |
| Ran `/agent` or skill directly | Runs in current pane only (no new windows) |

**Fix:** always `tmux new -s <name>` first, then launch `claude`.

### Essential tmux commands

**Sessions**

```
tmux new -s <name>      create a new session
tmux attach -t <name>   attach to an existing session
tmux ls                 list all sessions
Ctrl+b d                detach from session (leaves it running)
```

**Windows** (agents appear here)

```
Ctrl+b w        interactive window list — pick the agent you want to watch
Ctrl+b n        next window
Ctrl+b p        previous window
Ctrl+b c        create a new window manually
Ctrl+b ,        rename current window
Ctrl+b &        close current window
```

**Panes** (for splitting a window yourself)

```
Ctrl+b %        split vertically
Ctrl+b "        split horizontally
Ctrl+b o        cycle between panes
Ctrl+b arrow    move between panes
Ctrl+b z        zoom current pane to full screen (toggle)
Ctrl+b x        close current pane
```

**Scrolling** (to read an agent's full output)

```
Ctrl+b [        enter scroll mode
arrow / PgUp    scroll
q               exit scroll mode
```
