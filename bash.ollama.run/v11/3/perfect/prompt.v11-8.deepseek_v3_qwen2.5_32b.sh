# Define a completion function for 'ollama'
_ollama_completions() {
    # Check if the command is 'ollama' and previous word is 'run'; else return empty COMPREPLY
    local cur prev words cword
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion loaded (e.g., older versions)
        read -r -a words <<< "${COMP_WORDS[@]}"
        cword=${COMP_CWORD}
        prev="${words[$((cword-1))]}"
        cur="${words[cword]}"
    fi

    # Only handle completions for 'ollama run [model]' command
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve model names from `ollama list`, skipping header line and first column (NAME)
    local models=($(ollama list | awk 'NR>1 {print $1}'))
    if [ $? -ne 0 ]; then
        COMPREPLY=()
        return 0
    fi

    # Filter matches for completion; use compgen to generate possible completions
    local i word
    local match=()
    for word in "${models[@]}"; do
        if [[ "$word" == $cur* ]]; then
            match+=("$word")
        fi
    done

    # Sort and prepare the matches for completion, using __ltrim_colon_completions to handle colons properly
    local sorted_matches=$(printf "%s\n" "${match[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    
    # Call __ltrim_colon_completions to ensure proper display after colon (e.g., 'codellama:' should match correctly)
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
