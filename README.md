# terry-coding-agent-team

Personal Claude Code agents and skills, versioned so I can share the same setup across projects and machines.

## Contents

- `agents/` — Claude Code subagents (`coder`, `critic`, `reviewer`, `secretary`, `team-lead`).
- `skills/` — companion skills that drive the same workflow via slash commands (`backlog-coder`, `backlog-critic`, `eng-secretary`, `pr-reviewer`).

These are opinionated around a **markdown-backlog + PR workflow** — they expect a repo with a `BACKLOG.md` (or similar) and use `gh` for PR operations. They'll be less useful on projects without that structure.

## Install (user scope)

Clone anywhere and symlink into `~/.claude/`:

```sh
git clone git@github.com:terrykhm/terry-coding-agent-team.git ~/code/terry-coding-agent-team
cd ~/code/terry-coding-agent-team
./install.sh
```

`install.sh` symlinks each file in `agents/` and `skills/` into `~/.claude/agents/` and `~/.claude/skills/` respectively. Re-run it after `git pull` to pick up new files.

## Uninstall

```sh
./install.sh --uninstall
```

Removes only the symlinks this repo created; anything else in `~/.claude/agents` or `~/.claude/skills` is left alone.
