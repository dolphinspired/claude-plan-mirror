# claude-plan-mirror

This repo contains `src/mirror_plan.sh`, a Claude Code `PostToolUse` hook for the `Write` and `Edit` tools. When Claude writes or edits a file under `~/.claude/plans/`, the hook copies it into `plans/` in the current project directory using a stable `<repo-name>_<timestamp>.md` filename. Repeated writes/edits to the same source file overwrite the same destination, tracked via an HTML comment marker embedded in the source file itself — no external cache needed.

See `README.md` for installation instructions.

## What it does

When Claude writes a plan file to `~/.claude/plans/`, this hook:

1. Generates a destination filename: `<repo-name>_<ISO-timestamp>.md`
2. Copies the file to `<project-root>/plans/`
3. Appends `<!-- mirror-plan-to: {dest_filename} -->` to the source file

On subsequent writes (edits via the Edit tool preserve the marker), the hook reads the marker to find the existing destination and overwrites it. A full overwrite via the Write tool wipes the marker, so the next write generates a new destination — correctly distinguishing plan revisions from new plans.

## Configuration

Environment variables at the top of `src/mirror_plan.sh` control the paths:

| Variable | Default | Description |
|---|---|---|
| `GLOBAL_PLANS_PATH` | `$HOME/.claude/plans` | Where Claude writes plan files |
| `LOCAL_PLANS_FOLDER` | `plans` | Subdirectory within the project root to mirror into |

**1. Copy the hook script:**

```bash
cp src/mirror_plan.sh ~/.claude/hooks/mirror_plan.sh
```

**2. Add the hook to `~/.claude/settings.json`:**

See `src/hook_settings.json`. Merge with any existing `PostToolUse` hooks — don't replace the array.

## Testing

> **Note:** If you change `~/.claude/settings.json` (e.g. to add or modify hooks), you must relaunch Claude Code for the changes to take effect.

This hook can only be exercised by triggering Claude's `Write` and `Edit` tools — it cannot be tested with a standalone shell command because the hook fires as a side effect of Claude writing a file.

### Unit test (ask Claude to run this directly)

Tell Claude: _"Install and verify the hook"_ (or equivalent). Claude will:

1. Write `~/.claude/plans/hook_test.md` with `# Hook Test v1` via the Write tool.
2. Confirm a mirrored file appeared in `plans/` with `<repo-name>_<timestamp>.md` naming, and that the source file ends with `<!-- mirror-plan-to: {dest_filename} -->`.
3. Edit the source file to `# Hook Test v2` via the Edit tool.
4. Confirm the same destination file was overwritten (no new file), content updated.
5. Write to the source file again with `# Hook Test v3` via the Write tool — wipes the marker.
6. Confirm a second file appeared in `plans/` with a later timestamp (new plan identity).
7. Clean up: delete `~/.claude/plans/hook_test.md` and the two mirrored files.

### Integration test (real plan mode)

To verify the hook works end-to-end in real use:

1. Enter plan mode by asking Claude to plan something very simple (e.g. _"Plan how to write a script that prints 'X'"_).
2. Claude will write a plan file to `~/.claude/plans/` and exit plan mode.
3. Confirm a mirrored file appeared in `plans/` with the correct naming.
4. Ask Claude to revise the plan (e.g. _"Update the script to print 'Y' instead"_) — Claude will edit the existing plan file.
5. Confirm the same destination file was overwritten (no new file created).
6. Clean up the test plan files if desired.
