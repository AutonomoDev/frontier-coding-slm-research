#!/usr/bin/env bash

# ollama run completion function
_ollama_run_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being completed
    if [[ "${COMP_CWORD}" -eq 1 && "${COMP_WORDS[1]}" == "run" ]]; then
        # Only offer completions for the `ollama run <model>` command
        local models=$(ollama list 2>/dev/null)  # Capture ollama list output, suppress errors
        if [[ -n "$models" ]]; then
            COMPREPLY=($(compgen -W "${models}" -- "${cur}") )  # Filter and sort matches
        fi
    fi
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# Save this script to a file, e.g., `ollama-run-completion.bash`, then source it in your `.bashrc`:
# 
# echo 'source /path/to/ollama-run-completion.bash' >> ~/.bashrc
# source ~/.bashrc
# 
# After adding the above line, reload your shell configuration:
# 
# source ~/.bashrc
