_ollama_run_completion() {
    # Check if the command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Get the list of models from 'ollama list'
    local models=($(ollama list | tail -n +2 | awk '{print $1}' | grep -v '^$'))

    # Generate completions
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colons in completions (for models like llama2:13b)
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_run_completion ollama