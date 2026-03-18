# claude-plan-mirror

A Claude Code hook that mirrors plan files from `~/.claude/plans/` into the current project's `plans/` directory, with stable filenames across repeated writes.

## What it does

When Claude writes a plan file to `~/.claude/plans/`, this hook:

1. Generates a destination filename: `<repo-name>_<ISO-timestamp>.md`
2. Copies the file to `<project-root>/plans/`
3. Records the source → destination mapping in `plans/.mirror_cache.json`

On subsequent writes to the same source file, the hook overwrites the same destination rather than creating a new one. This keeps the `plans/` directory clean across plan revisions.

## Requirements

- [`jq`](https://jqlang.github.io/jq/) must be available on `PATH`
- Claude Code

## Installation

**1. Copy the hook script:**

```bash
cp mirror_plan.sh ~/.claude/hooks/mirror_plan.sh
```

**2. Add the hook to `~/.claude/settings.json`:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/mirror_plan.sh"
          }
        ]
      }
    ]
  }
}
```

Merge with any existing `PostToolUse` hooks — don't replace the array.

## Configuration

Two variables at the top of `mirror_plan.sh` control the paths:

| Variable | Default | Description |
|---|---|---|
| `GLOBAL_PLANS_PATH` | `$HOME/.claude/plans` | Where Claude writes plan files |
| `LOCAL_PLANS_FOLDER` | `plans` | Subdirectory within the project root to mirror into |

## Testing

See `CLAUDE.md` — testing requires Claude to trigger the hook by writing a file, so the test procedure is described there for Claude to follow directly.
