# [[HUMAN COMMENTED-OUT]]
#Here's the rewritten file - since this appears to be a valid, complete Bash script that defines a completion function, I'll keep it mostly as-is, just ensuring proper formatting:

# Function to generate completions for 'ollama run' command
_ollama_completions() {
    local cur prev models cur_save wordbreaks_backup

    # Check if first argument is "run"
    [[ ${COMP_WORDS[1]} != "run" ]] && return

    # Save original COMP_WORDBREAKS to restore later
    wordbreaks_backup=$COMP_WORDBREAKS
    # Remove colon from COMP_WORDBREAKS to correctly parse model names with colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    # Re-parse the command line using _get_comp_words_by_ref -n : to handle colons properly
    local index=$((COMP_CWORD-1))
    _get_comp_words_by_ref cur prev :="$index"
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS=$wordbreaks_backup

    if [[ $prev == "run" ]]; then
        # Retrieve model names using ollama list command
        models=$(ollama list | awk 'NR>1 {print $1}')
        # Generate reply array COMPREPLY with word completions for the model names
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register function as completion handler for 'ollama' command
complete -F _ollama_completions ollama
