# Function to generate completions for `ollama run`
function _ollama_completions() {
    local cur prev words cword split
    COMPREPLY=()
    # Get the current word and previous word
    _get_comp_words_by_ref -n :cur:prev

    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons in the current word
    __ltrim_colon_completions "$cur"

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Get list of models from ollama list
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Filter models matching the current prefix
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for `ollama run`
complete -F _ollama_completions ollama
