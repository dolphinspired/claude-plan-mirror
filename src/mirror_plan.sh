#!/usr/bin/env bash
# PostToolUse hook for Write
# When a file is written to GLOBAL_PLANS_PATH, mirrors it to LOCAL_PLANS_FOLDER in the current
# project directory. Repeated writes to the same source file overwrite the same destination,
# tracked via CACHE_FILE_PATH in the local plans folder.

GLOBAL_PLANS_PATH="$HOME/.claude/plans"
LOCAL_PLANS_FOLDER="plans"
CACHE_FILE_PATH="$(dirname "$0")/.mirror_cache.json"

# Reads stdin, extracts the written file path, and validates it is under GLOBAL_PLANS_PATH.
# Prints the file path if valid, empty string otherwise.
read_plan() {
    local input file_path
    input=$(cat)
    file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    [[ "$file_path" == "$GLOBAL_PLANS_PATH/"* ]] && echo "$file_path"
}

# Given a source file path, returns the absolute destination path in the local plans folder.
# Checks CACHE_FILE_PATH first; creates a new timestamped entry if not found.
get_plan_path() {
    local file_path="$1"
    local plans_dir dest cache
    plans_dir="$(pwd)/$LOCAL_PLANS_FOLDER"
    mkdir -p "$plans_dir"

    cache=$([[ -f "$CACHE_FILE_PATH" ]] && cat "$CACHE_FILE_PATH" || echo '{}')

    dest=$(printf '%s' "$cache" | jq -r --arg k "$file_path" '.[$k] // empty')
    if [[ -z "$dest" ]]; then
        local repo_name timestamp
        repo_name=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr ' -' '_' | tr -cd '[:alnum:]_')
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        dest="$plans_dir/${repo_name}_${timestamp}.md"
        printf '%s' "$cache" | jq --arg k "$file_path" --arg v "$dest" '.[$k] = $v' > "$CACHE_FILE_PATH"
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
