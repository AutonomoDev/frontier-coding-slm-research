# ollama-run-completion.sh

_ollama_run_completion() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()

    # Check if the previous command was 'ollama run' and there are no more arguments provided
    if [[ "${COMP_WORDS[1]}" == "run" && $COMP_CWORD -eq 2 ]]; then
        local models=$(ollama list 2>/dev/null)
        if [ $? -eq 0 ]; then
            COMPREPLY=($(compgen -W "$models" -- "$current_word"))
        fi
    else
        # For other cases, provide a default completion (if needed)
        COMPREPLY=( $(compgen -W "" -- "$current_word") )
    fi
}

complete -F _ollama_run_completion ollama run

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save the script to a file, e.g., `ollama-run-completion.sh`.
# 2. Source this script from your `.bashrc` or equivalent initialization file:
#    source /path/to/ollama-run-completion.sh
# 3. Activate the completion by running:
#    complete -F _ollama_run_completion ollama run

