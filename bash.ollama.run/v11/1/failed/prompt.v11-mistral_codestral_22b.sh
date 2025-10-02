 # Define completion function for 'ollama' command
_ollama_completions() {
    # If not 'ollama', return early with empty COMPREPLY
    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colon in word breaks - use _get_comp_words_by_ref for bash-completion systems, else fallback to standard parsing
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if previous word is 'run'
    if [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # If ollama command does not exist, do not generate completions
    if ! type -p ollama > /dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Generate model name completions
    local models matches sorted_matches i
    IFS=$'\n' read -d '' -ra models < <(ollama list | awk 'NR > 1 {print $1}') || return 0
    for ((i=0; i<${#models[@]}; ++i)); do
        if [[ ${models[i]} =~ ^$cur ]]; then
            matches+=("${models[i]}")
        fi
    done

    # Sort and generate COMPREPLY, or set to empty array for no match
    if (( ${#matches[@]} > 0 )); then
        sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
        COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    else
        COMPREPLY=()
    fi

    # Properly handle colon-separated completions display after setting COMPREPLY
    __ltrim_colon_completions "$cur"
}

# Register the function for 'ollama' command completion
complete -F _ollama_completions ollama

