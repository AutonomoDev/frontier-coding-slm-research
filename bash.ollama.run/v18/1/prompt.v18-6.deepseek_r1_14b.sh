# Bash completion script for `ollama run`

function _ollama_completions() {
    # Check if the command is `ollama run`
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return 0
    }
    # Ensure we're completing after exactly two words (i.e., `ollama run`)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev
    # Get current and previous word, handling colons properly
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    local models=()
    # Parse `ollama list` to extract model names
    if command -v ollama &>/dev/null; then
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    fi

    # Sort the models alphabetically
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate completions based on the sorted models
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colon completion for model names like `codellama:13b`
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function with bash
complete -F _ollama_completions ollama
