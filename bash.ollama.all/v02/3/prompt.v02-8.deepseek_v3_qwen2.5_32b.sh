#!/bin/bash

_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        show|run|stop|push|cp|rm)
            # Fetch models only if 'ollama' is installed and returns non-empty list
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            # Generate completions based on current input word
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            # Sort and trim colons from completions if present
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
        ;;
        create)
            local options='--file -f --quantize -q'
            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
        ;;
    esac

    # Handle top-level completion (when previous word is 'ollama')
    if [[ $prev == ollama ]]; then
        local commands='show run stop push cp rm create serve pull signin signout list ps help'
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    fi
}

# Register the completion function with 'ollama' command
complete -F _ollama_completions ollama