#!/bin/bash
# This is a Bash completion script for the `ollama run` command.
# It provides completions for model names containing colons (e.g., `codellama:13b`, `codegemma:7b`).

_get_comp_words_by_ref() {
    # Manual fallback when helper unavailable
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
}

_ollama_run() {
    local -a models
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || return 1

    # Find the exact position of "run" in COMP_WORDS array
    local run_index=0
    for ((i = 0; i < ${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when COMP_CWORD == run_index + 1
    local model_regex="^${cur//:/\\:}"
    if [ "$COMP_CWORD" -ne $((run_index + 1)) ]; then
        return 0
    fi

    # CORRECT: Handle variable whitespace in awk
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '$0 !~ /:/' | awk '{print $1}')
    if [ -z "$models" ]; then
        return 1
    fi

    # PREFERRED: Safe prefix matching
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    return 0
}
complete -F _ollama_run ollama

