```bash
#!/bin/bash

# _ollama_run_completions - Generates completions for 'ollama run' command.
_ollama_run_completions() {
    local cur prev opts wordbreaks models cmd_part

    # Handle colon in model names by modifying COMP_WORDBREAKS
    wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=$wordbreaks

    # Only complete for 'run' subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Fetch models from 'ollama list'
    opts=$(ollama list | awk 'NR>1 {print $1}')

    COMPREPLY=()
    cur=${cur:-""}

    # Generate completions based on current input
    if [[ "$cur" == "" ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "") )
    else
        COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completions ollama
```

