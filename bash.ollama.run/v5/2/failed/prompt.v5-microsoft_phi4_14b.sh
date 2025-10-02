# This is a Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names based on the output of `ollama list`.

_ollama_run_completion() {
    # Ensure we are in the correct context by checking if the second word is 'run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Fallback to manually setting variables if `_get_comp_words_by_ref` fails or is unavailable
    if [[ $? -ne 0 ]]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the current context is `ollama run`
    if [[ ${#words[@]} -lt 2 || words[1] != "run" ]]; then
        return  # Exit if not in the correct subcommand context
    fi

    # Get the list of available models from `ollama list`, skipping the header line
    local model_list
    model_list=$(ollama list | tail -n +2)

    # Extract only the model names using cut, and filter based on the current word being typed
    COMPREPLY=($(compgen -W "${model_list##*$'\n'}" -- "$cur"))

    # Ensure unique suggestions by removing duplicates
    if [[ ${#COMPREPLY[@]} -gt 1 ]]; then
        declare -A seen
        local filtered_completions=()
        for item in "${COMPREPLY[@]}"; do
            if [[ -z "${seen[$item]}" ]]; then
                seen["$item"]=1
                filtered_completions+=("$item")
            fi
        done
        COMPREPLY=( "${filtered_completions[@]}" )
    fi

    # Do not fall back to file completions or provide any output if no match is found
}
1
# Register the completion function with bash-completion
complete -F _ollama_run_completion ollama

