_ollama_completion() {
    local cur prev words cword

    _init_completion -n : || return

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        # Exit early since we only want to complete for 'ollama run <model>'
        return 1
    fi

    local models=$(ollama list | awk 'NR>1 && NF {print $1}' | tr '\n' ' ')

    COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )

    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completion ollama
