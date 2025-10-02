# Robust Bash completion script for 'ollama run' command with colon-handling.
_ollama_completions() {
    local cur prev words=() cword opts cmd

    # Check if the current command is 'ollama'.
    cmd="${COMP_WORDS[0]}"
    if [[ "$cmd" != "ollama" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Parse current and previous word correctly, handling colons.
    # Use _get_comp_words_by_ref for compatibility with bash-completion.
    if ! type _get_comp_words_by_ref &> /dev/null; then
        # Fallback to standard COMP_WORDS parsing without colon handling.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    else
        # Use -n : flag to prevent splitting on colons, crucial for model names like 'codellama:34b'.
        if ! _get_comp_words_by_ref -n : cur prev; then
            COMPREPLY=()
            return 0
        fi
    fi

    # Only complete models after 'ollama run'.
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve model names from 'ollama list' command.
    local models=()
    if ! ollama list &> /dev/null; then
        # Handle case where ollama is not installed or fails.
        COMPREPLY=()
        return 0
    fi
    while read -r line; do
        # Skip header lines (NAME, etc.).
        if [[ "$line" =~ ^NAME ]]; then
            continue
        fi
        # Extract model name from first column.
        local model=$(echo $line | awk '{print $1}')
        models+=("$model")
    done < <(ollama list)

    # Filter matches based on current word (cur).
    local matched=()
    for m in "${models[@]}"; do
        if [[ "$m" == "$cur"* ]]; then
            matched+=("$m")
        fi
    done

    # Generate completions with compgen.
    COMPREPLY=( $(compgen -W "${matched[*]}" -- "$cur") )

    # Handle colon-separated completion display.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command.
complete -F _ollama_completions ollama
