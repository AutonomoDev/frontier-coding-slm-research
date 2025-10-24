# Ollama Completion Script for Bash

_ollama_completions() {
    # Check if _get_comp_words_by_ref is available (bash-completion v2+)
    type _get_comp_words_by_ref &>/dev/null || return 1

    local IFS=$' \t\n'
    local cur prev words cword
    COMPREPLY=()

    # Save the original word break characters and modify to remove colon
    local old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${old_wb//:/}

    # Re-parse command line with modified COMP_WORDBREAKS
    _get_comp_words_by_ref -n : cur prev words cword

    # Restore original word breaks to avoid side effects
    COMP_WORDBREAKS=${old_wb}

    # Only complete model names after "ollama run"
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi

    return 0
}

complete -F _ollama_completions ollama

