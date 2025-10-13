# Define completion function for ollama run command
_ollama_run_completions() {
    local cur prev words cword split
    _init_completion || return

    # Save original COMP_WORDBREAKS and remove ':'
    local orig_COMP_WORDBREAKS=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Reparse current and previous words
    _get_comp_words_by_ref -n : cur prev words cword split
    [[ $split == true ]] && return 0

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS=$orig_COMP_WORDBREAKS

    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        local IFS=$'\n'
        COMPREPLY=($(compgen -W "$(ollama list | tail -n +2 | awk '{print $1}')" -- "$cur"))
    fi
}

# Register completion function for ollama run command
complete -F _ollama_run_completions ollama
