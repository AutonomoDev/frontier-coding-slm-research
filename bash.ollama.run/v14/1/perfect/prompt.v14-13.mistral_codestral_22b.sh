# Declare function for completion script
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Try getting current and previous word considering colon
    local cur prev words
    _get_comp_words_by_ref -n : cur prev words || \
        { cur=${words[$((${#words[@]} - 1))]}; prev=${words[$(( ${#words[@]} - 2 ))]}; }

    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Get all models from `ollama list` output
    local models=( $(ollama list 2>/dev/null | sed '1d' | awk '{print $1}') )

    # Filter models based on current prefix and generate completions
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Fix colon display for model names with colons
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama
