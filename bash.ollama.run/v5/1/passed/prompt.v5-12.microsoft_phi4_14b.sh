# This Bash completion script provides autocompletion for the `ollama run` command.
# It is designed to be sourced, e.g., `source my_script.sh`.

_ollama_run_completion() {
    # Check if we are completing the 'run' subcommand of 'ollama'
    local cur prev words cword
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev words cword

    # Ensure that we're at the correct position in the command line for completion.
    if [[ ${cword} -ne 2 || "${words[1]}" != "run" ]]; then
        return 0
    fi

    # Get the list of available models from `ollama list`.
    local model_list
    model_list=$(ollama list | sed '1d' | awk '{print $1}')

    # Filter model names based on the current word being typed.
    COMPREPLY=( $(compgen -W "${model_list}" -- "$cur") )
}

# Register the completion function for `ollama run`.
complete -F _ollama_run_completion ollama

# Fallback mechanism if `_get_comp_words_by_ref` is not available.
if ! type _get_comp_words_by_ref > /dev/null 2>&1; then
    _ollama_run_completion_fallback() {
        local cur prev words cword
        COMPREPLY=()

        # Manually retrieve current and previous word if `_get_comp_words_by_ref` is missing.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Ensure that we're at the correct position in the command line for completion.
        if [[ $COMP_CWORD -ne 2 || "${COMP_WORDS[1]}" != "run" ]]; then
            return 0
        fi

        # Get the list of available models from `ollama list`.
        local model_list
        model_list=$(ollama list | sed '1d' | awk '{print $1}')

        # Filter model names based on the current word being typed.
        COMPREPLY=( $(compgen -W "${model_list}" -- "$cur") )
    }

    complete -F _ollama_run_completion_fallback ollama
fi

# End of script.

