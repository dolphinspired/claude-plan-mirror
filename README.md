# claude-plan-mirror

```
⚠️ This README is human-generated! ⚠️
```

I got tired of fighting with Claude's context to get it to consistently write plan files to the current directory before executing them. This is my attempt at a deterministic fix. Whenever the Write or Edit tools are used on `~/.claude/plans` (folder where Claude places plan files by default), that file is then mirrored to the "plans" folder in the current working directory (presumably repo root), suffixed with a timestamp.

Some notes about the implementation:

* We hook into the Write/Edit tools because I could not find a reliable hook for "a plan has been accepted". So this script runs on every Write/Edit, but only acts on file writes to Claude's global plans folder. Maybe there will be a better hook in a future Claude Code release.
  * You can set a "[plansDirectory](https://claudelog.com/faqs/what-is-plans-directory-in-claude-code/)", but this just changes the folder. We have no native way that I know of to control the filename on a per-project basis.
* Since Claude re-uses global plan files per-session (not per-plan), there's no built-in mechanism for distinguishing between different plans made within the same session. The script works around this by embedding an HTML comment when the file is first created which indicates the target file. Edits to this plan will retain the comment, causing the same file to get overwritten, but new plan mode usages will overwrite the file completely, causing a new HTML marker (and therefore new file) to get written.

## Requirements

Assumes you're running Claude Code and have [`jq`](https://jqlang.github.io/jq/) available in your `PATH`.

## Installation

Just point Claude at this repo and ask them to "install and verify the hook". On the first run, this will change your Claude Code settings, so you'll need to restart Claude for it to take effect. Relaunch, then just ask them to "verify the hook" to test your installation. Instructions are all in [CLAUDE.md](./CLAUDE.md).

If you wanna change the global folder from `~/.claude/plans/` or the local folder from `./plans`, just ask Claude to change it when they install the script.

## Live Testing

Claude will do a smoke test by writing files directly to the plans directory and verifying that they get mirrored over. But the best test is just to play around with plan mode. You can see the kinds plans I generated above. Here's what I did to test:

* Enter plan mode (shift-tab twice)
  * **Prompt:** "Plan out a script that goes 'meow'."
    * **Result:** A new timestamped plan file is created in `./plans`.
  * Don't confirm. Instead, ask for edits, like "no actually make it say 'meow' twice, it's a talkative kitty"
    * **Result:** That same plan file in `./plans` should be updated.
  * Finally, confirm the plan. And enjoy your new "meow" script.
* Enter plan mode again.
  * **Prompt:** "Plan out a script that goes 'bark'."
    * **Result:** A new timestamped plan file is created in `./plans`, and the original meow plan remains unchanged.
  * Don't confirm, ask for edits like "oh I think this one should say 'BARK' in all caps because this is one loud pup"
    * **Result:** 2nd plan file in `./plans` is modified, 1st plan remains unchanged.
  * Commit to the bit and enjoy your BARK script.

## Validation

Works on my box.

