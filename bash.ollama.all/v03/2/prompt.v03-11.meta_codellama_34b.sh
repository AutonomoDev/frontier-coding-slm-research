
```
#!/bin/bash

# Completion script for ollama command line tool

# Main function
_ollama_completions() {
    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fetch models (handle missing ollama command and empty model list)
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions (use compgen to generate the completions)
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort and trim (ltrim_colon_completions to sort and trim the results)
    __ltrim_colon_completions "$cur"
}

# Register completion function at the end with complete -F _ollama_completions ollama
complete -F _ollama_completions ollama
```

