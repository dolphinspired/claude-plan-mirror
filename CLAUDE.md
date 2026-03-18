# claude-plan-mirror

This repo contains `src/mirror_plan.sh`, a Claude Code `PostToolUse` hook for the `Write` tool. When Claude writes a file under `~/.claude/plans/`, the hook copies it into `plans/` in the current project directory using a stable `<repo-name>_<timestamp>.md` filename. Repeated writes to the same source file overwrite the same destination, tracked via a global cache file that lives alongside the installed script (default: `~/.claude/hooks/.mirror_cache.json`, configurable via `CACHE_FILE_PATH`). Both keys and values in the cache are full absolute paths, so the cache works correctly across all projects.

See `README.md` for installation instructions.

## What it does

When Claude writes a plan file to `~/.claude/plans/`, this hook:

1. Generates a destination filename: `<repo-name>_<ISO-timestamp>.md`
2. Copies the file to `<project-root>/plans/`
3. Records the source → destination mapping in `plans/.mirror_cache.json`

On subsequent writes to the same source file, the hook overwrites the same destination rather than creating a new one. This keeps the `plans/` directory clean across plan revisions.

## Configuration

Environment variables at the top of `src/mirror_plan.sh` control the paths:

| Variable | Default | Description |
|---|---|---|
| `GLOBAL_PLANS_PATH` | `$HOME/.claude/plans` | Where Claude writes plan files |
| `LOCAL_PLANS_FOLDER` | `plans` | Subdirectory within the project root to mirror into |
| `CACHE_FILE_PATH` | `./.mirror_cache.json` | Full path to the global cache file tracking source → destination mappings (lives alongside the installed script) |

**1. Copy the hook script:**

```bash
cp src/mirror_plan.sh ~/.claude/hooks/mirror_plan.sh
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

## Testing

This hook can only be exercised by triggering Claude's `Write` tool — it cannot be tested with a standalone shell command because the hook fires as a side effect of Claude writing a file. To test it:

1. Write a test plan file to `~/.claude/plans/hook_test.md` with some identifiable content (e.g. `# Hook Test v1`).
2. Confirm a mirrored file appeared in `plans/` with the expected `<repo-name>_<timestamp>.md` naming.
3. Write to `~/.claude/plans/hook_test.md` again with updated content (e.g. `# Hook Test v2`).
4. Confirm the same destination file was overwritten (no new file created), and its content matches the update.
5. Confirm `~/.claude/hooks/.mirror_cache.json` contains an entry mapping the absolute source path (`~/.claude/plans/hook_test.md`) to the absolute destination path.
6. Clean up: delete `~/.claude/plans/hook_test.md`, the mirrored file, and the cache entry (or the whole cache file if it only has the test entry).
