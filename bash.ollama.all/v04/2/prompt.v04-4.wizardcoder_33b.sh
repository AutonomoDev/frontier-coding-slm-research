_ollama_completions() {
    local cur prev words cword models
    _get_comp_words_by_ref -n : cur prev words cword
  
    if ((cword == 1)); then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
        return
    fi
  
    case ${prev} in 
        ollama)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' )
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        stop)
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}' )
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create|pull)
            COMPREPLY=()
            ;;
        show|run|push|cp|rm)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' )
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models --file -f --quantize -q" -- "$cur"))
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
    esac
  
    COMPREPLY=( $(compgen -W "${COMPREPLY[@]}" -- "$cur" ) )
}
  
complete -F _ollama_completions ollama
