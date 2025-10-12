 ```bash
#!/usr/bin/env bash

# Bash completion script for ollama run command
_ollama_run_completions() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur -n :prev -n :words -n :cword -n :split

    # Check if the second word is "run"
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Save and modify COMP_WORDBREAKS to handle colons in model names
    local original_comp_wordbreaks=$COMP_WORDBREAKS
    COMPREPLY=()
    compopt -o nospace
    COMPREPLY=( $(compgen -W "$(ollama list | tail -n +2 | awk '{print $1}')" -- "$cur") )
    # Restore COMP_WORDBREAKS to its original state
    COMP_WORDBREAKS=$original_comp_wordbreaks
}

# Register the completion function for ollama run command
complete -F _ollama_run_completions ollama
```

