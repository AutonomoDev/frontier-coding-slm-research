_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    local models=()
    while IFS= read -r line; do
        # Skip header and empty lines
        [[ "$line" =~ ^NAME\ ID\ SIZE\ MODIFIED$ || -z "$line" ]] && continue
        models+=("${line%% *}")
    done < <(ollama list)

    COMPREPLY=( $(compgen -W "${models[@]}" -- $cur) )
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
