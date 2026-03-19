# claude-plan-mirror

```
🚨 This README is human-generated! 🚨
```

**tl;dr** I want to keep a running list of plan files in my repo and Claude kept fighting me on it, so I came up with a deterministic fix using Claude's event hooks.

## The Problem

When you use plan mode in Claude Code, it writes all plan docs to a global folder like this:

```bash
~/.claude/plans/{session_name}.json
```

The `{session_name}` seems to be a randomly-generated three-word phrase by default. You can currently control this with the [`"plansDirectory"`](https://claudelog.com/faqs/what-is-plans-directory-in-claude-code/)" property in `~/.claude/settings.json`:

```jsonc
// This will write plan files to the "plans" folder in the current working directory instead.
{
  "plansDirectory": "./plans"
}
```

However, there are still problems left unsolved by this setting:

* We still have **no control over the filename** that I know of. You can rename your session with `/rename`, but you have to remember to do this each time. The plan is always _just_ the session name - you can't choose another naming scheme.
* If you run multiple plans in one session (e.g. a long-running conversation), **the subsequent plan will overwrite the previous one**.
  * This leads me to believe that plans were intended to be ephemeral, but I prefer having a running list of them kept with the project, so I can maintain an understanding of how the project developed over time.
* There does not seem to be a natural language way to get Claude to consistently write a copy of the plan to the project directory. I believe this happens because:
  * Plan mode is inherently read-only, thus plans cannot be written to files as they're being developed.
  * Context is usually erased immediately after accepting a plan, so Claude will forget unless you embed the instruction to "write this plan to a file" directly into the plan itself. (reminding Claude to do this with every plan is tedious and a waste of tokens)

In addition, there does not seem to be an event hook that reliably executes "when a plan is accepted". Some research suggested the existence of an "ExitPlanMode" but I couldn't get this to work.

## My Observations & Solution

This repo documents an approach that I've found works **deterministically** - just a script and event hooks, no extra language processing. And you don't need to change the `"plansDirectory"` setting.

Although we don't have a hook for exiting plan mode, we do have two tools that Claude executes every time a plan is written:

* **Write**: Called once, the first time a plan is drafted, even on subsequent plans in the same session.
* **Edit**: Called each time you prompt Claude to update a plan during plan mode.

This script simply hooks into Write and Edit, listens for files written to the default plans directory, and then adds a simple HTML comment to the end of the document if it doesn't have one.

```html
<!-- mirror-plan-to: {dir_name}_{timestamp}.md -->
```

Where `{dir_name}` is the folder name of the current working directory.

The script then has the following effects:

* When you're in plan mode and the first draft is written, **Write** will completely overwrite whatever plan is at `{session_name}.md`. The script will observe that there is no HTML comment and add one, using the current `{timestamp}` as a suffix.
* The script will then **make a copy of the plan file** to the plans folder, following that naming convention.
  * The HTML comment is stripped out of the project's copy of the plan. It's only needed on the source copy.
  * When you have Claude make edits to that same plan, **Edit** will modify the file, but the HTML comment will persist. So the updated plan file will be **copied over to the same destination** that's in the HTML comment, overwriting the previous draft of the plan.
* After that plan is executed, if you enter plan mode again, this will trigger a **Write** call and the process begins with a new timestamp and file.

The final result? Exactly what I wanted: a running list of plan documents, scoped to the working directory, automatically written every time I use plan mode. 🎉

## Setup

### Requirements

Assumes you're running Claude Code and have [`jq`](https://jqlang.github.io/jq/) available in your `PATH`.

### Installation

Just point Claude at this repo and ask them to "install and verify the hook". On the first run, this will change your Claude Code settings, so you'll need to restart Claude for it to take effect. Relaunch, then just ask them to "verify the hook" to test your installation. Instructions are all in [CLAUDE.md](./CLAUDE.md).

If you wanna change the global folder from `~/.claude/plans/` or the local folder from `./plans`, just ask Claude to change it when they install the script.

### Live Testing

Claude will do a smoke test by writing files directly to the plans directory and verifying that they get mirrored over. But the best test is just to play around with plan mode. You can see the kinds of plans I generated in the `./plans` folder in this repo. Here's what I did to test:

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

### How reliable is it?

Works on my box.
