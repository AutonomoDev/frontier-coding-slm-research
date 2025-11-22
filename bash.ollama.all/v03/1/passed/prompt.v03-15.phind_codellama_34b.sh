# [[HUMAN COMMENTED-OUT]]
# Here's a bash completion script for `ollama`:

_ollama_completions() {
    local cur prev opts subcommands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # top level completion
    if [[ "$prev" == "ollama" ]]; then
        subcommands="create show run stop push cp rm serve start pull signin signout list ls ps help"
        COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
        return 0
    fi

    case "${prev}" in
        create|pull)
            opts="--file -f --quantize -q --insecure"
            COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
            ;;
        run)
            if [[ "$cur" == * ]] ; then
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
            else
                opts="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
            fi
            ;;
        show)
            if [[ "$cur" == * ]] ; then
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
            else
                opts="--license --modefile --parameters --system --template --verbose"
                COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
            fi
            ;;
        stop|rm)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
            ;;
        *)
            COMPREPLY=()
            ;;
    esac

    __ltrim_colon_completions "$cur"
    return 0
} && complete -F _ollama_completions ollama
