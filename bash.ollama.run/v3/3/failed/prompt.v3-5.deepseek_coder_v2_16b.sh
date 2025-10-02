# ollama_run_completion.sh

_ollama_run_completion() {
    local cur prev comps opts
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev

    # Check if the previous word is "run" and command is "ollama"
    if [[ "$prev" == "run" && "$COMP_WORDS[1]" == "ollama" ]]; then
        comps=$(ollama list 2>/dev/null)
        if [ -n "$comps" ]; then
            COMPREPLY=($(compgen -W "$(echo "$comps" | sort)" -- "$cur"))
        fi
    fi
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#Installation instructions:
#
#1. Save the script to a file, e.g., `ollama_run_completion.sh`.
#2. Source or source this script in your `.bashrc` or equivalent initialization file:
#   ```bash
#   source /path/to/ollama_run_completion.sh
#   ```
#3. Reload your shell configuration:
#   ```bash
#   source ~/.bashrc
#   ```

