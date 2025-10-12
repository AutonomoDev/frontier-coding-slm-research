#!/bin/bash

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fallback if _get_comp_words_by_ref fails
    if [[ -z "$cur" ]]; then
        cur="${COMP_WORDS[2]}"
    fi

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Run ollama list and parse output
    local models
    while IFS= read -r line; do
        [[ "$line" == "NAME"* ]] && continue  # Skip header line
        echo "$line" | awk '{print $1}' >> /tmp/ollama_models.txt
    done < <(ollama list 2>/dev/null)

    models=$(cat /tmp/ollama_models.txt)
    rm -f /tmp/ollama_models.txt

    # Generate completions based on current prefix
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Sort results and set COMPREPLY
    COMPREPLY=($(for comp in "${COMPREPLY[@]}"; do echo "$comp"; done | sort))

    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama