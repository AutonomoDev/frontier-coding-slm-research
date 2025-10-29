# Bash completion for `ollama run` command

complete -F _ollama_completions ollama

function _ollama_completions {
    # Check if command is exactly "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    # Handle colon completion cases
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Ensure ollama command exists and parse models
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions from model names
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completion results
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completion suggestions if needed
    __ltrim_colon_completions "$cur"
}
