#!/bin/bash

# Define a Bash function named `_ollama_completions` that provides tab completion for the `ollama` command line tool.
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Top-level completion: If the previous word is `ollama`, provide a list of all subcommands as completions.
    if [[ "$cur" == "ollama" ]]; then
        COMPREPLY=($(compgen -W "$(ollama --help | awk '/^ \{5\}/ {print $1}')"))
        return 0
    fi

    # Model name completion logic:
    case "$prev" in
        create)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- $cur))
            else
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- $cur))
            fi
            ;;
        run|stop|push|cp|rm)
            if [[ "$cur" != -* ]]; then
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- $cur))
            fi
            ;;
    esac

    # Sort and trim the completions.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama`.
complete -F _ollama_completions ollama