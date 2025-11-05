_ollama_completions() {
    local cur prev subcommands="show run stop push cp rm create serve pull signin signout list ps help"
    local model_commands="show run stop push cp rm"

    # Check if previous word is 'ollama' to complete top-level commands
    _get_comp_words_by_ref -n : cur prev words cword
    [[ $prev == ollama ]] && { COMPREPLY=($(compgen -W "$subcommands" -- "$cur")); return; }

    # Extract subcommand (second word)
    local cmd=${words[1]}

    case $cmd in
        # Commands requiring model completion
        $(echo $model_commands | tr ' ' '\n') )
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            # Sort completions and trim colons (if any)
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create )
            local options="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$options" -- "$cur"))
            ;;
        # No completions for other commands
        *)
            COMPREPLY=()
            ;;
    esac
}

# Register the completion function with 'ollama'
complete -F _ollama_completions ollama

