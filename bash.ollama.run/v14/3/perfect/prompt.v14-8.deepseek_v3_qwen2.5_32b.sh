_ollama_completions() {
    # Check if command is 'ollama run' by verifying COMP_WORDS[0] (command) and [1] (first argument)
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    # Handle colons in completion, allowing model names like 'codellama:'
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback to manual extraction if _get_comp_words_by_ref fails
        # This is unlikely but ensures compatibility with older bash versions
        local cword=$COMP_CWORD
        let cword-=1
        prev="${COMP_WORDS[cword]}"
        cur="$COMP_WORDS[$cword+1]"
    fi

    # Check if 'ollama' command exists to prevent errors
    command -v ollama &>/dev/null || { COMPREPLY=(); return; }

    # Fetch and parse model names from `ollama list` output, skipping header line
    local models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}')

    # Filter models matching current prefix (cur) using compgen
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Fix colon completion display issue; without this, nothing appears after ':'
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
