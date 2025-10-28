```bash
#!/bin/bash

# Function for ollama completions
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama is installed and available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse models from ollama list
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions using compgen and wrap in ()
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort COMPREPLY with printf | sort
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Handle colons and trim prefix from COMPREPLY elements
    __ltrim_colon_completions "$cur"
}

# Register the ollama completion function
complete -F _ollama_completions ollama
```

