# [[HUMAN COMMENTED-OUT]]
# Here is a possible Bash completion script for `ollama`:

_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        create)
            if [[ $cur == --* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi
            ;;
        run|stop|push|cp|rm)
            # Model name completion logic
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        serve|pull|signin|signout|list|ps|help)
            ;;
        *)
            COMPREPLY=($(compgen -W "create run stop push cp rm serve pull signin signout list ps help" -- "$cur"))
            ;;
    esac
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script follows the prompt's guidelines and uses a `case` statement to handle different completion types. It also provides model name completions for commands from Group 1, as specified in the prompt.
