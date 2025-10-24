_ollama_run_completion() {
    # Save the original COMP_WORDBREAKS value
    old_wb=$COMP_WORDBREAKS

    # Remove ':' from COMP_WORDBREAKS for parsing model names
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Check if _get_comp_words_by_ref is available, and use it to set cur and prev variables
    if declare -F _get_comp_words_by_ref > /dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        # If not available, manually set cur and prev from COMP_WORDS and COMP_CWORD
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Ensure the completion is triggered for the token immediately following 'run'
    run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ ${COMP_WORDS[$i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only perform completion if the current word is immediately after 'run'
    if [[ $run_index -ge 0 && $COMP_CWORD == $((run_index+1)) ]]; then
        # Get the list of available local models and filter it by the current word being typed
        local models=()
        while IFS= read -r line; do
            [[ ${line} =~ ^[[:space:]]*$ || $line == NAME* ]] && continue
            model=$(echo "$line" | awk 'NR>1 {print $1}')
            [[ "${model}" == ${cur}* ]] && models+=("${model}")
        done < <(ollama list 2>/dev/null)

        # If no models match, do not provide any suggestions
        if (( ${#models[@]} > 0 )); then
            # Ensure the final suggestions are unique and sorted
            compopt -o nospace 2>/dev/null
            COMPREPLY=( $(printf '%s\n' "${models[@]}" | awk '!seen[$0]++') )
        fi
    fi

    # Restore the original COMP_WORDBREAKS value
    COMP_WORDBREAKS=$old_wb
}

# Register the function with bash-completion for the 'ollama' command and its 'run' subcommand
complete -F _ollama_run_completion ollama

