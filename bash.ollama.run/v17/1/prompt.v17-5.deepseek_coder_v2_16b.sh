 ```bash
#! /usr/bin/env bash

function _ollama_completions {
    local cur prev words cword split
    _init_completion -s || return

    # Ensure the subcommand is "run"
    if [[ "$prev" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS and remove colon from it temporarily
    local original_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKE//:}"

    # Re-parse the command line with updated COMP_WORDBREAKS
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$original_comp_wordbreaks"

    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Generate the list of models
    local model_list=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions based on the current word (cur)
    compgen -W "$model_list" -- "$cur"

    # Call the bash-completion helper to handle colon correctly
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama
```

