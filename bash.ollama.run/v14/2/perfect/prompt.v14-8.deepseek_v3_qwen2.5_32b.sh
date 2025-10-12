_ollama_completions() {
    # Check if the first two words are 'ollama' and 'run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    # Try to get current and previous word, treating colon as part of the word
    _get_comp_words_by_ref -n : cur prev || {
        # Fallback: manually extract from COMP_WORDS based on cursor position
        ((COMP_CWORD == 2)) && cur="${COMP_WORDS[2]}"
    }

    local models=()
    if command -v ollama &>/dev/null; then
        while read -r line; do
            case "$line" in
                'NAME'*|'') continue ;; # Skip header and empty lines
                *) models+=("$(echo $line | awk '{print $1}')") ;;
            esac
        done < <(ollama list 2>/dev/null)
    else
        COMPREPLY=(); return;
    fi

    # Filter models matching current input prefix
    local matches=$(compgen -W "${models[*]}" -- "$cur")

    # Assign completions and handle colon completion
    COMPREPLY=( $matches )
    __ltrim_colon_completions "$cur"  # Essential for colon support (e.g., codellama:)
}

complete -F _ollama_completions ollama
