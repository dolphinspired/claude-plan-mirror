# claude-plan-mirror

```
This README is human-generated.
```

I got tired of fighting with Claude's context to get it to consistently write plan files to the current directory before executing them. This is my attempt at a deterministic fix. Whenever a Write tool is used on `~/.claude/plans` (where Claude places plan files by default), that file is then mirrored to the "plans" folder in the current working directory (presumably repo root), suffixed with a timestamp.

Some notes about the implementation:

* We hook into the Write tool because I could not find a hook for a plan file being generated. So this script runs on every Write, but only acts on writes to Claude's global plans folder. Maybe there will be a better hook in a future Claude Code release.
* The script maintains a small JSON cache that maps global plan file paths to project plan file paths. This is so subsequent attempts to one global plan file will be reflected in the same project-level plan file.
* You may need to change the directory from `~/.claude/plans/` if your setup is different. Read [CLAUDE.md](./CLAUDE.md) for implementation details.

## Requirements

Assumes you're running Claude Code and have [`jq`](https://jqlang.github.io/jq/) available in your `PATH`.

## Installation

Easiest way is probably just to ask Claude to "install and verify the hook". They're smart enough. I'm sure they can figure it out. (in other words, instructions are in [CLAUDE.md](./CLAUDE.md))

Since this relies on Claude's hooks to work, you have to let them test it.
