_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Only provide completions for 'ollama run <model>'
    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return 0
    fi

    # We're completing the model name (position 2: ollama run [model])
    if [[ "${COMP_WORDS[1]}" == "run" && $cword -eq 2 ]]; then
        local models=()
        while IFS= read -r line; do
            models+=("$line")
        done < <(ollama list | tail -n +2 | awk '{print $1}')

        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
        __ltrim_colon_completions "$cur"
    fi
}

complete -F _ollama_completions ollama