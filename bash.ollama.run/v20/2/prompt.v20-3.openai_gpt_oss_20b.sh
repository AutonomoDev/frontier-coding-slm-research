# Thinking...
# We need to output only bash code. The function _ollama_completions must be as per steps. Must include inline comments for key logic. Avoid arrays for models, so we keep models as scalar string. We must use compgen -W "$models". Must handle colon trimming via __ltrim_colon_completions. Must call complete -F _ollama_completions ollama. No markdown. Also ensure no array usage for models. Use printf etc. Let's produce.
# 
# Note: Need to ensure that _get_comp_words_by_ref is called with -n :. That is fine.
# 
# Check that we use local cur prev. Ok.
# 
# We need to ensure we don't use COMP_CWORD or fallback logic. We must not use arrays. The code uses COMPREPLY=($(compgen -W "$models" -- "$cur")). This expands to array; but COMPREPLY is an array variable. It's acceptable. We must not use arrays for models; we are using scalar string models.
# 
# We also need to sort COMPREPLY by printing each element and sorting.
# 
# The __ltrim_colon_completions "$cur" is used after sorting.
# 
# Return safely on missing/empty models: after checking if command exists and if models empty.
# 
# Ok. Let's produce final answer.
# ...done thinking.

_ollama_completions() {
    # Ensure we're completing for `ollama run`
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get current and previous word, ignoring colons
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Exit if ollama command isn't available
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Retrieve the list of models as a single string
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions for the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions and trim any leading colons
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
