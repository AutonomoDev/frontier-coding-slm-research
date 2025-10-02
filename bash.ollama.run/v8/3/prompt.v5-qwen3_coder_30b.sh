# Bash completion function for 'ollama run' command
# Handles model names with colons correctly using COMP_WORDBREAKS manipulation

_ollama_run_completion() {
    # Save original COMP_WORDBREAKS to restore later
    local old_wb="$COMP_WORDBREAKS"

    # Find the position of "run" in COMP_WORDS, accounting for potential subcommands
    local run_index=-1
    local i
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only provide completions when we're completing the model name after 'run'
    if [[ $run_index -ge 0 && $COMP_CWORD -eq $((run_index + 1)) ]]; then
        # Remove colon from COMP_WORDBREAKS to prevent splitting on colons
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Get model names using robust parsing (handles variable whitespace)
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Restore original COMP_WORDBREAKS before any early returns or exits
        COMP_WORDBREAKS="$old_wb"

        # Use compgen for safe prefix matching (avoids regex issues)
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Restore COMP_WORDBREAKS if not completing model name
        COMP_WORDBREAKS="$old_wb"
        # Clear COMPREPLY to avoid filename completion fallback
        COMPREPLY=()
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completion ollama

