# claude-plan-mirror

```
This README is human-generated.
```

I got tired of fighting with Claude's context to get it to consistently write plan files to the current directory before executing them. This is my attempt at a deterministic fix. Whenever a Write tool is used on `~/.claude/plans` (where Claude places plan files by default), that file is then mirrored to the "plans" folder in the current working directory (presumably repo root), suffixed with a timestamp.

Some notes about the implementation:

* We hook into the Write tool because I could not find a hook for a plan file being generated. So this script runs on every Write, but only acts on writes to Claude's global plans folder. Maybe there will be a better hook in a future Claude Code release.
* Since Claude re-uses global plan files per-session (not per-plan), there's no built in mechanism for distinguishing between different plans made within the same session. The script works around this by embedding an HTML comment when the file is first created which indicates the target file. Edits to this plan will retain the comment, and overwrites of this plan will not, so a new filename will get written.
* You may need to change the directory from `~/.claude/plans/` if your setup is different. Read [CLAUDE.md](./CLAUDE.md) for implementation details.

## Requirements

Assumes you're running Claude Code and have [`jq`](https://jqlang.github.io/jq/) available in your `PATH`.

## Installation

Just point Claude at this repo and ask them to "install and verify the hook". On the first run, this will change your Claude Code settings, so you'll need to restart Claude for it to take effect. Relaunch, then just ask them to "verify the hook" to test your installation. Instructions are all in [CLAUDE.md](./CLAUDE.md).
