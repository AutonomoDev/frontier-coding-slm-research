```bash
#!/bin/bash

# Function: _ollama_completions()
function _ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Local variables: cur, prev
    local cur prev

    # Get current and previous words
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama is installed and list models
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=(); return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # Check if there are any models
    if [ -z "$models" ]; then
        COMPREPLY=(); return
    fi

    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Fix colons
    __ltrim_colon_completions "$cur"
}

# Register completion function
complete -F _ollama_completions ollama
```

