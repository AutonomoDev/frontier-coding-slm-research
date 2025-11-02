# Bash completion script for 'ollama run <model>'
_ollama_run_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}  # Current word being completed
    if [[ ${COMP_CWORD} -ne 2 || "${COMP_WORDS[1]}" != "run" ]]; then
        return  # Exit if not completing 'ollama run' command
    fi

    local models=$(ollama list 2>/dev/null)  # Capture ollama list output, suppress errors
    if [[ -z "$models" ]]; then
        return  # Exit if no models found or ollama list fails
    fi

    COMPREPLY=()
    for model in $models; do
        if [[ ${model} == "${cur}"* ]]; then  # Filter by current word prefix
            COMPREPLY+=(${model})
        fi
    done
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        return  # Exit if no matches found
    fi

    # Sort and assign to COMPREPLY
    IFS=$'\n' COMPREPLY=($(sort <<<"${COMPREPLY[*]}"))
    unset IFS
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save the script somewhere, for example, `~/.bash_completion.d/ollama-run-completion.sh`.
# 2. Add the following line to your `.bashrc` or equivalent initialization file:
#    source ~/.bash_completion.d/ollama-run-completion.sh
# 3. Reload your shell configuration by running `source ~/.bashrc` (or equivalent).
