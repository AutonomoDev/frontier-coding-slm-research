_ollama() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ "${words[0]}" != "ollama" || "${words[1]}" != "run" ]]; then
        return
    fi

    case "$prev" in
        run)
            local models=()
            while IFS= read -r line; do
                if [[ "$line" =~ ^NAME.*ID.*SIZE.*MODIFIED$ ]] || [[ -z $line ]]; then
                    continue
                else
                    model=$(echo "$line" | awk '{print $1}')
                    models+=("$model")
                fi
            done < <(ollama list)

            COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
    esac
}
complete -F _ollama ollama
