_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    case ${prev} in
        run | stop | push | cp | rm)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        pull)
            local flags="--insecure"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            [[ ${COMPREPLY[0]} =~ ^-.* ]] || { unset COMPREPLY[0]; }
            ;;
        run)
            local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            [[ ${COMPREPLY[0]} =~ ^-.* ]] || { unset COMPREPLY[0]; }
            ;;
        show)
            local flags="--license --modefile --parameters --system --template --verbose"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            [[ ${COMPREPLY[0]} =~ ^-.* ]] || { unset COMPREPLY[0]; }
            ;;
        serve | start | signin | signout | list | ls | ps | help)
            COMPREPLY=()
            return
            ;;
    esac

    if [[ ${cur} == "ollama" ]]; then
        local subcommands="show run stop push cp rm create pull serve start signin signout list ls ps help"
        COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
    fi
}
complete -F _ollama_completions ollama
