# Bash completion for `ollama run <model>`
_ollama_run_completion() {
    local cur prev ollama_list

    # Fallback if _get_comp_words_by_ref is missing or fails
    if ! type -t _get_comp_words_by_ref &>/dev/null; then
        case "$COMP_CWORD" in
            1) cur="$2"; prev="$3" ;;
            *) compgen -W "$(echo "$COMP_LINE" | tr ' ' '\n' | cut -d' ' -f$((COMP_CWORD-1)))" -- "$cur" ;;
        esac
        return 0
    fi

    _get_comp_words_by_ref cur prev

    if [[ "${prev}" != "run" ]]; then
        return 1
    fi

    ollama_list=$(ollama list 2>/dev/null)

    if [[ -z "$ollama_list" ]]; then
        return 1
    fi

    local models=($(echo "$ollama_list" | grep "^$cur"))

    if [[ ${#models[@]} -eq 0 ]]; then
        return 1
    fi

    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
}

complete -F _ollama_run_completion ollama

# Installation instructions:
# Add this line to your .bashrc or equivalent configuration file:
# source /path/to/your/script.sh
# Then reload the shell configuration:
# exec $SHELL -l

