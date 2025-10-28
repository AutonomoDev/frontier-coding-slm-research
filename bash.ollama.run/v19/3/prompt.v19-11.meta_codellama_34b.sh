```bash
#!/bin/bash

# Completion script for "ollama run" command.
# Make sure to have __ltrim_colon_completions() function defined before sourcing this script,
# usually by sourcing the bash-completion package's tab-completion script first.

# Function for ollama run command completion
_ollama_completions() {
    # Check if "ollama" is the first word and "run" is the second word on the command line.
    # If not, do nothing.
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Get current and previous words without colons.
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # If ollama command is not found, do nothing.
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse output of "ollama list" to get a list of models.
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # If there are no models, do nothing.
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions based on the list of models and the current word.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # If the current word has a colon, trim the prefix from completions.
    if [[ $cur == *:* ]]; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion function for "ollama" command.
complete -F _ollama_completions ollama
```

