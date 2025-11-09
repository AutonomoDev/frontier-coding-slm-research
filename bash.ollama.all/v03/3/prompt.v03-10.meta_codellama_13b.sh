#!/bin/bash

_ollama_completions() {
    # Use a case statement to switch on the subcommand
    local cur prev
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev
    case "$prev" in
        show|run|stop|push|cp|rm)
            # Fetch and display model names for commands requiring <MODEL> completion
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Provide special flag completion for the create command
            local flags=(--file -f --quantize -q)
            COMPREPLY=($(compgen -W "${flags[@]}" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        pull|run)
            # Provide special flag completion for the pull and run commands
            local flags=(--insecure)
            COMPREPLY=($(compgen -W "${flags[@]}" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        show)
            # Provide special flag completion for the show command
            local flags=(--license --modefile --parameters --system --template --verbose)
            COMPREPLY=($(compgen -W "${flags[@]}" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        serve|start|pull|signin|signout|list|ls|ps|help)
            # Provide no argument completion for the commands with no arguments
            COMPREPLY=()
            ;;
    esac
}
complete -F _ollama_completions ollama