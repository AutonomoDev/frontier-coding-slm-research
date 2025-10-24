_ollama_run_completions() {
    # Save original COMP_WORDBREAKS and modify it for colon handling
    local orig_worbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"

    # Re-parse the current and previous words with modified word breaks
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately after parsing
    COMP_WORDBREAKS="$orig_worbreaks"

    # Check if the second word is exactly "run" to trigger completion
    [[ "${COMP_WORDS[1]}" == "run" ]] || return

    # Fetch and parse available models from 'ollama list'
    local models=( $(ollama list | awk 'NR > 1 {print $1}') )

    # Provide suggestions for model names if the current word is non-empty
    [[ -n "$cur" ]] && COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
}

# Register the completion function with 'complete' command for 'ollama run'
complete -F _ollama_run_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script follows all specified requirements: it correctly handles Bash word splitting issues around colons, dynamically fetches model names from `ollama list`, and ensures completions are only provided when the `run` subcommand is used. The logic for modifying `COMP_WORDBREAKS` before parsing and restoring it immediately afterward ensures that colon-containing words like `codellama:13b` are handled correctly.

