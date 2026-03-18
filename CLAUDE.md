# claude-plan-mirror

This repo contains `mirror_plan.sh`, a Claude Code `PostToolUse` hook for the `Write` tool. When Claude writes a file under `~/.claude/plans/`, the hook copies it into `plans/` in the current project directory using a stable `<repo-name>_<timestamp>.md` filename. Repeated writes to the same source file overwrite the same destination, tracked via `plans/.mirror_cache.json`.

See `README.md` for installation instructions.

## Testing

This hook can only be exercised by triggering Claude's `Write` tool — it cannot be tested with a standalone shell command because the hook fires as a side effect of Claude writing a file. To test it:

1. Write a test plan file to `~/.claude/plans/hook_test.md` with some identifiable content (e.g. `# Hook Test v1`).
2. Confirm a mirrored file appeared in `plans/` with the expected `<repo-name>_<timestamp>.md` naming.
3. Write to `~/.claude/plans/hook_test.md` again with updated content (e.g. `# Hook Test v2`).
4. Confirm the same destination file was overwritten (no new file created), and its content matches the update.
5. Confirm `plans/.mirror_cache.json` contains exactly one entry mapping `hook_test.md` to the destination filename.
6. Clean up: delete `~/.claude/plans/hook_test.md`, the mirrored file, and `plans/.mirror_cache.json`.
