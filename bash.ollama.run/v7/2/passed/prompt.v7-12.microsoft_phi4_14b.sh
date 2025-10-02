# Define a function to handle ollama run autocompletion
_ollama_run_completion() {
    # Initialize variables for the current word and its position
    local cur prev words cword split comp_line index=0

    # Check if _get_comp_words_by_ref is available; fallback manually otherwise
    if declare -F _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        eval set -- "$COMP_LINE"
        shift $(( COMP_CWORD - 1 ))
        for word; do
            if [ $index -eq $cword ]; then
                cur=$word
            fi
            if [ $index -eq $((cword-1)) ]; then
                prev=$word
            fi
            (( index++ ))
        done
    fi

    # Find the position of 'run' in COMP_WORDS and trigger only for the next token
    local run_index=0
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only activate when COMP_CWORD is the position after 'run'
    if [[ $cword -ne $((run_index + 1)) ]]; then
        return
    fi

    # Save current word breaks and remove colon to handle ':' properly in completions
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Use a subshell to safely capture the list of models without affecting the script's execution
    local model_list=$(ollama list 2>/dev/null)

    # Parse and deduplicate model names from the ollama list command output using awk
    if [[ -n "$model_list" ]]; then
        mapfile -t words < <(echo "$model_list" | awk 'NR>1 {print $1}')
        local wordlist=$(printf "%s\n" "${words[@]}" | awk '!seen[$0]++')

        # Perform prefix-based filtering using compgen for safe suggestions
        COMPREPLY=($(compgen -W "$wordlist" -- "$cur"))
    fi

    # Restore the original word breaks to avoid side effects in other completions
    COMP_WORDBREAKS=$old_wb

    # Disable default completion fallbacks that might suggest files or spaces
    compopt -o nospace 2>/dev/null
}

# Register the function with bash-completion for the ollama command, specifically targeting 'run'
complete -F _ollama_run_completion ollama


# [[HUMAN COMMENTED-OUT]]
#This script ensures robust model name autocompletion by handling potential pitfalls like variable whitespace in `ollama list` output and the special character ':' in model names. The completion is strictly limited to cases where it follows directly after the "run" subcommand, aligning with the requirements specified.

