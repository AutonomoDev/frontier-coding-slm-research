# [[HUMAN COMMENTED-OUT]]
# Here is a sample Bash completion script for `ollama run <model>`:

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons in model names (e.g., codellama:13b)
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    if [[ "$cur" == ":" ]]; then
        __ltrim_colon_completions "$cur"
    fi

    # Parse models from ollama list output
    local ollama_output
    if command -v ollama &>/dev/null; then
        ollama_output=$(ollama list 2>/dev/null)
    else
        return
    fi
    local -a models=()
    while IFS=' ' read -r name _; do
        if [[ "$name" != "NAME" ]]; then
            models+=("$name")
        fi
    done <<< "$ollama_output"

    # Generate completions
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    __ltrim_colon_completions "$cur"  # NEVER SKIP THIS!
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Note that this script uses the `_get_comp_words_by_ref` function from the Bash completion library to handle colons in model names. It also uses the `command` utility to check if the `ollama` command exists, and skips parsing its output if it doesn't. Finally, it sets the `COMPREPLY` variable correctly with an array of matching model names.
