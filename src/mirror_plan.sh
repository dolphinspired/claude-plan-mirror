#!/usr/bin/env bash
# PostToolUse hook for Write and Edit
# When a file is written or edited under GLOBAL_PLANS_PATH, mirrors it to LOCAL_PLANS_FOLDER in
# the current project directory. The destination is tracked via an HTML comment marker embedded
# in the source file itself — no external cache needed.

GLOBAL_PLANS_PATH="$HOME/.claude/plans"
LOCAL_PLANS_FOLDER="plans"

PLAN_MIRROR_MARKER='<!-- mirror-plan-to: %s -->'
PLAN_MIRROR_PATTERN="${PLAN_MIRROR_MARKER//%s/\\([^ ]*\\)}"
# PLAN_MIRROR_PATTERN → "<!-- mirror-plan-to: \([^ ]*\) -->"

# Reads stdin, extracts the written file path, and validates it is under GLOBAL_PLANS_PATH.
# Prints the file path if valid, empty string otherwise.
read_plan() {
    local input file_path
    input=$(cat)
    file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    [[ "$file_path" == "$GLOBAL_PLANS_PATH/"* ]] && echo "$file_path"
}

# Given a source file and local plans dir, extracts the dest filename from the mirror marker.
# Prints the full absolute destination path if found, empty string otherwise.
get_mirror_dest() {
    local file="$1" plans_dir="$2"
    local dest_filename
    dest_filename=$(sed -n "s/.*${PLAN_MIRROR_PATTERN}.*/\1/p" "$file" | head -1)
    [[ -n "$dest_filename" ]] && echo "$plans_dir/$dest_filename"
}

# Given a source file path, returns the absolute destination path in the local plans folder.
# Reads the mirror marker from the source file; appends a new marker if none is found.
get_plan_path() {
    local file_path="$1"
    local plans_dir dest
    plans_dir="$(pwd)/$LOCAL_PLANS_FOLDER"
    mkdir -p "$plans_dir"

    dest=$(get_mirror_dest "$file_path" "$plans_dir")

    if [[ -z "$dest" ]]; then
        local repo_name timestamp dest_filename
        repo_name=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr ' -' '_' | tr -cd '[:alnum:]_')
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        dest_filename="${repo_name}_${timestamp}.md"
        dest="$plans_dir/$dest_filename"
        # shellcheck disable=SC2059
        printf "\n${PLAN_MIRROR_MARKER}\n" "$dest_filename" >> "$file_path"
    fi

    echo "$dest"
}

# Copies the source plan to the destination path and logs the result.
write_plan() {
    local src="$1" dest="$2"
    cp "$src" "$dest"
    echo "mirror_plan: wrote $dest" >&2
}

main() {
    if ! command -v jq &>/dev/null; then
        echo "mirror_plan: jq not found, skipping" >&2
        return
    fi

    local file_path dest
    file_path=$(read_plan)
    [[ -z "$file_path" ]] && return

    dest=$(get_plan_path "$file_path")
    write_plan "$file_path" "$dest"
}

main
