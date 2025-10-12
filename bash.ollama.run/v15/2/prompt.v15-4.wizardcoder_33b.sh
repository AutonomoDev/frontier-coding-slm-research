```bash
_ollama_run_completions() {
    local prev cur original_wordbreaks words models comp_line
    
    # Save the original word breaks and remove colon, to handle model names with colons correctly.
    original_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    _get_comp_words_by_ref -n : cur prev words comp_line
    
    # Restore the original word breaks.
    COMP_WORDSREAKS=$original_wordbreaks

    # Only provide completions for the 'run' subcommand.
    if [[ "${prev}" == "run" ]]; then
        models=( $(/usr/local/bin/ollama list | tail -n +2 | awk '{print $1}') )
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

# Register the function with bash.
complete -F _ollama_run_completions ollama
``` 

