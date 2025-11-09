# [[HUMAN COMMENTED-OUT]]
# Bash Completion Script for `ollama`

# Function definition for Ollama command completions
function _ollama_completions() {
    local cur prev opts

    # Fetch current and previous words from the line buffer
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev

    case "${prev}" in
        "show"|"run"|"stop"|"push"|"cp"|"rm")
            # Fetch model names for commands that require <MODEL> completion
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
        ;;
        "create")
            # Provide completions for 'create' command flags
            opts="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
        "pull")
            # Provide completion for 'pull' command flag
            opts="--insecure"
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
        "run")
            # Provide completions for 'run' command flags
            opts="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
        "show")
            # Provide completions for 'show' command flags
            opts="--license --modefile --parameters --system --template --verbose"
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
        *)
            # Provide top-level command completion
            local commands="serve start pull signin signout list ls ps help create show run stop push cp rm"
            COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
    esac
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
