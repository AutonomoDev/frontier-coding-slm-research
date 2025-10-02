_ollama_run_completion() {
 # Save current COMP_WORDBREAKS and temporarily remove ':'
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Get the index of the "run" command in COMP_WORDS
    run_index=$(for i in "${!COMP_WORDS[@]}"; do [[ ${COMP_WORDS[i]} == "run" ]] && echo "$i" && break; done)

    # If current word is immediately after "run", then provide completion suggestions
    if [[ $COMP_CWORD -eq run_index+1 ]]; then
        cur="${COMP_WORDS[COMP_CWORD]}"  # The word being typed currently

        # Get the list of available models by running 'ollama list' and parsing its output
        mapfile -t models < <( ollama list | awk 'NR>1 {print $1}' ) || true

        # If 'ollama list' failed or returned nothing, gracefully exit without suggestions
        if (( ${#models[@]} == 0 )); then
            return 0
        fi

        # Generate completion suggestions that match the current word being typed
        COMPREPLY=( $( compgen -W "${models[*]}" -- "$cur" ) )
    else
        # If not at the correct position, do nothing (no completion)
        :
    fi

    # Restore original COMP_WORDBREAKS and exit
    COMP_WORDBREAKS=$old_wb
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama
