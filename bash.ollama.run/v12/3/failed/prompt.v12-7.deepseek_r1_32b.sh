#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main goal is to have it complete model names from `ollama list`, especially handling those with colons correctly.
#
#First, I'll structure the function as `_ollama_completions`. It needs to check if the first word is "ollama" and the previous word is "run". If not, set COMPREPLY to empty and return early. That's straightforward.
#
#Next, handling colons is crucial because Bash splits words on colons by default. I'll use `_get_comp_words_by_ref -n : cur prev` to prevent splitting. But I should add a fallback in case this function isn't available, using COMP_WORDS directly for `cur` and `prev`.
#
#For the completion logic, when `prev` is "run", I need to check if `ollama` exists. If it doesn't, return early. Then, run `ollama list` and parse its output. The header line and empty lines should be skipped, extracting only the first column for model names.
#
#I'll store these model names in an array called `models`. If this array is empty, set COMPREPLY to empty. Otherwise, find matches that start with `$cur`, sort them, and use `compgen` to generate completions.
#
#After setting COMPREPLY, I must call `__ltrim_colon_completions "$cur"` to ensure suggestions display correctly after a colon. This step is critical because without it, the completion won't show up properly when a colon is present.
#
#Finally, register the function with `complete -F _ollama_completions ollama` and add comments explaining each part, especially the handling of colons and why trimming is necessary.
#
#I'll make sure to use local variables, handle errors by redirecting output to /dev/null, and set COMPREPLY appropriately in all cases. This should result in a robust completion script that works well with `ollama run`.
#...done thinking.

_ollama_completions() {
    # Only complete for 'ollama run' command
    local first_word=${COMP_WORDS[0]}
    if [[ "$first_word" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colon correctly in model names
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after 'run'
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Get model names from 'ollama list'
    local models=()
    while IFS=$'\n' read -r line; do
        if [[ "$line" =~ ^NAME.*$ ]]; then
            continue  # Skip header
        fi
        if [[ -z "$line" ]]; then
            continue  # Skip empty lines
        fi
        local model=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model" ]]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # No models available
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Find matching models
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches for consistent ordering
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completions
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Fix colon handling in completion display
    __ltrim_colon_completions "$cur"

    return 0
}

complete -F _ollama_completions ollama
