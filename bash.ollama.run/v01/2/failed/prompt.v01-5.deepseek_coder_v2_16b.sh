# ollama-run-completion.sh

_ollama_run_completions() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()

    if [[ "${COMP_CWORD}" -eq 1 ]]; then
        # Complete the command itself
        COMPREPLY=( $(compgen -W "run" -- "$current_word") )
    elif [[ "${COMP_CWORD}" -gt 1 ]]; then
        local prev_word="${COMP_WORDS[COMP_CWORD-1]}"
        if [[ "$prev_word" == "ollama" && "$current_word" == "" ]]; then
            # Get models list from ollama list command
            local models=$(ollama list 2>/dev/null)
            if [[ $? -eq 0 ]]; then
                COMPREPLY=( $(compgen -W "$models" -- "$current_word") )
            fi
        fi
    fi
}

complete -F _ollama_run_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save the script as `ollama-run-completion.sh`.
# 2. Source this script from your `.bashrc` or equivalent initialization file:
#    source /path/to/ollama-run-completion.sh
# 3. Activate the completion function by reloading your shell configuration:
#    source ~/.bashrc  # Or ~/.zshrc, depending on your shell setup
# 4. Now you can use `ollama run <Tab>` to trigger model name suggestions.
