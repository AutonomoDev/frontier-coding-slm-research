# Bash completion script for `ollama run` command
_ollama_completions() {
    local cur prev words cword split
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback to COMP_WORDS parsing if bash-completion is not available
        compopt -o default
        COMPREPLY=()
        return 1
    fi

    if [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    local models=$(ollama list | awk 'NR>1 {print $1}')
    local IFS=$'\n'
    local matches=($(compgen -W "$models" -- "${cur}"))

    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
    else
        COMPREPLY=("${matches[@]}")
    fi

    # Handle colon completions properly
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
