# ollama run command completion script

_ollama_run_completion() {
    local cur prev words cword split=false
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable
        compopt -o nosort
        COMPREPLY=()
        return
    }

    if [[ "$cword" -eq 1 ]]; then
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Find the exact position of "run" in COMP_WORDS array
        local run_index=$((${#COMP_WORDS[@]} - 1))
        if [[ "${COMP_WORDS[run_index]}" == "run" ]]; then
            local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
        else
            # If not triggering on "run", clear the completions
            COMPREPLY=()
        fi
    fi
}

complete -F _ollama_run_completion ollama


# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Function Definition**: The function `_ollama_run_completion` is defined to handle the completion logic for the `ollama run` command.
#2. **Fallback Handling**: If the helper function `_get_comp_words_by_ref` is unavailable, it falls back to manually setting `COMPREPLY`.
#3. **Position Detection**: It checks if the current word (`cur`) is at the position after "run" in the command line.
#4. **Model List Retrieval**: If completing after "run", it retrieves model names using `ollama list` and filters them based on the current input prefix (`cur`).
#5. **Completion Generation**: It uses `compgen -W` to generate completions from the available models, ensuring safe prefix matching.
#6. **Command Registration**: The function is registered with `complete -F _ollama_run_completion ollama` to be invoked for the `ollama run` command.
#7. **No Filename Fallback**: When not providing model completions, it ensures `COMPREPLY=()` to avoid any unintended outputs.

