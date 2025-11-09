 # Generated Bash Completion Script for `ollama`

```bash
# Define the main completion function
function _ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case $prev in
        # Commands requiring '<MODEL>' completion
        "show" | "run" | "stop" | "push" | "cp" | "rm")
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            # Fetch the list of model names
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            # Generate completions for '<MODEL>' argument
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        # 'create' command with special flag completion
        "create")
            local flags="--file -f --quantize -q"
            # Complete flags or models based on previous word
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                _ollama_model_completion
            fi
            ;;
        # 'pull' command with special flag completion
        "pull")
            local flags="--insecure"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                _ollama_model_completion
            fi
            ;;
        # 'run' command with special flag completion
        "run")
            local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                _ollama_model_completion
            fi
            ;;
        # 'show' command with special flag completion
        "show")
            local flags="--license --modefile --parameters --system --template --verbose"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            else
                _ollama_model_completion
            fi
            ;;
        # 'stop' command with model completion from `ollama ps`
        "stop")
            local ids
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            # Fetch the list of running model IDs using 'ollama ps'
            ids=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $2}')
            [[ -z "$ids" ]] && { COMPREPLY=(); return; }
            # Generate completions for '<ID>' argument
            COMPREPLY=($(compgen -W "$ids" -- "$cur"))
            ;;
        *)
            # Top-level completion: provide a list of all subcommands as completions
            local commands="create run serve start stop show pull push cp rm ls ps signin signout help"
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    esac
}

# Helper function for model completion logic
function _ollama_model_completion() {
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    # Fetch the list of model names using 'ollama list'
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    # Generate completions for '<MODEL>' argument and sort the result
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
```

