#!/bin/bash

_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        ollama)
            COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
            return 0
            ;;
        show|run|stop|push|cp|rm)
            # Step A: Extract Word Info
            _get_comp_words_by_ref -n : cur prev

            # Step B: Fetch Models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C: Generate Completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D: Sort and Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return 0
            ;;
        create)
            local flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            return 0
            ;;
        serve|pull|signin|signout|list|ps|help)
            # No argument completion needed for these commands
            COMPREPLY=()
            return 0
            ;;
    esac
}

complete -F _ollama_completions ollama