_ollama() {
    local cur prev words cword split
    _init_completion -n : || return

    case "${words[cword]}" in
        run)
            if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
                COMPREPLY=()
                return
            fi
            local models=$(ollama list | awk 'NR>1 && $1!="" {print $1}' | sort -u)
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            __ltrim_colon_completions "$cur"
        ;;
        *)
    esac
}
complete -F _ollama ollama
