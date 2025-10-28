 ```bash
# Bash completion for `ollama run`
_ollama_completions() {
    # Check if command is 'ollama run' and position of cursor
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Handle colons in arguments
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse output of 'ollama list' command to get available models
    local models=()
    if command -v ollama &>/dev/null; then
        mapfile -t models < <(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    fi

    # Sort the models to provide a consistent completion order
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate completions based on current input
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Fix completions after colons for insertion
    if type __ltrim_colon_completions &>/dev/null; then __ltrim_colon_completions "$cur"; fi
}

# Register the completion function
complete -F _ollama_completions ollama
   ```

