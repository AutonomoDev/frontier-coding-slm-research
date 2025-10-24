#!/bin/bash

_ollama_completion() {
    # Get current and previous words
    local cur prev
    if ! _get_comp_words_by_ref cur prev 2>/dev/null; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    # Only complete after "ollama run"
    if [[ "$prev" != "run" ]] || [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return 0
    fi
    
    # Get ollama list output once and store in variable
    local ollama_output
    ollama_output=$(ollama list 2>/dev/null) || return 0
    
    # Extract model names, filter by prefix, and collect matches
    local models=()
    local line model
    while IFS= read -r line; do
        # Skip header line and empty lines
        [[ -z "$line" || "$line" =~ ^NAME ]] && continue
        # Extract first field (model name) - everything before first whitespace
        model="${line%% *}"
        # Filter by current prefix and add to array
        [[ -n "$model" && "$model" == "$cur"* ]] && models+=("$model")
    done <<< "$ollama_output"
    
    # Sort matches and populate COMPREPLY
    if [[ ${#models[@]} -gt 0 ]]; then
        # Sort alphabetically using process substitution to avoid subshell
        readarray -t models < <(printf '%s\n' "${models[@]}" | sort)
        COMPREPLY=("${models[@]}")
    fi
}

# Register completion function for ollama command
complete -F _ollama_completion ollama
