```bash
_ollama_run_completions() {
    # Save the original COMP_WORDBREAKS value
    local orig_worbreaks="$COMP_WORDBREAKS"
    
    # Temporarily remove ':' from COMP_WORDBREAKS to handle model names with colons
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
    
    # Re-parse the current and previous words using the modified word break settings
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Restore the original COMP_WORDBREAKS value immediately after re-parsing
    COMP_WORDBREAKS="$orig_worbreaks"
    
    # Check if the second word is "run" to activate completion for ollama run subcommand only
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Fetch and parse available model names from 'ollama list'
        local models=( $(ollama list | awk 'NR>1 {print $1}') )
        
        # Use compgen to generate suggestions for the current word position
        COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    fi
}

# Register the completion function with the 'ollama' command, specifically for the 'run' subcommand
complete -F _ollama_run_completions ollama
```

This script adheres to all specified requirements: it modifies `COMP_WORDBREAKS` temporarily to handle model names containing colons, ensures completions are triggered only for the `run` subcommand by checking the correct position in `COMP_WORDS`, and dynamically fetches and suggests model names from the output of `ollama list`. The completion function is registered using `complete -F _ollama_run_completions ollama`.

