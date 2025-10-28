# Thinking...
# We need to output bash code only, no markdown. Function _ollama_completions. Must do checks. Include comments explaining critical sections. Ensure all requirements. Use complete -F. Provide robust script. Let's craft.
# ...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run <model>`
# This script follows the strict requirements specified:
#  - Activates only for the command "ollama run"
#  - Handles colon-separated model names correctly
#  - Parses the output of `ollama list` to generate completions
#  - Sorts the completions and trims the colon prefix

# Ensure the required bash completion helper is available
# If not, the script will not register the completion
if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
    return 2
fi

_ollama_completions() {
    # Ensure the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Use the helper to parse the current word and the previous word,
    # stripping any colon prefix for colon-completion handling.
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Verify that the `ollama` command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=(); return
    fi

    # Retrieve the list of models as a single string (scalar)
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    # If there are no models, exit early
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions using compgen and store them in COMPREPLY
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions for a consistent order
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Remove the colon prefix from the completion list
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the "ollama" command
complete -F _ollama_completions ollama
