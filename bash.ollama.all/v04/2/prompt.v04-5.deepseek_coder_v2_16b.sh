_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ $cword -eq 1 ]]; then
        case "$prev" in
            show|run|stop|push|cp|rm|create|pull) COMPREPLY=();;
            serve|start|signin|signout|list|ls|ps|help) COMPREPLY=();;
            *)
                local commands="show run stop push cp rm create pull serve start signin signout list ls ps help"
                COMPREPLY=($(compgen -W "$commands" -- $cur))
                ;;
        esac
    else
        case "${words[1]}" in
            show)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=(-license -modefile -parameters -system -template -verbose)
                else
                    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                    COMPREPLY=($(compgen -W "$models" -- $cur))
                fi
                ;;
            run)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=(--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose)
                else
                    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                    COMPREPLY=($(compgen -W "$models" -- $cur))
                fi
                ;;
            stop)
                local models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- $cur))
                ;;
            push|cp|rm)
                local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- $cur))
                ;;
            create)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=(--file -f --quantize -q)
                else
                    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                    COMPREPLY=($(compgen -W "$models" -- $cur))
                fi
                ;;
            pull)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=(--insecure)
                else
                    COMPREPLY=()
                fi
                ;;
        esac
    fi
}

complete -F _ollama_completions ollama