# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for the `ollama` command:

# Main function for ollama completions
_ollama_completions() {
    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Switch on subcommand
    case "$prev" in
        create)
            # For the `create` command, complete with flags
            local flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            ;;
        pull)
            # For the `pull` command, complete with flags and models
            local flags="--insecure"
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            COMPREPLY=($(compgen -W "$flags $models" -- "$cur"))
            ;;
        run)
            # For the `run` command, complete with flags and models
            local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            COMPREPLY=($(compgen -W "$flags $models" -- "$cur"))
            ;;
        show)
            # For the `show` command, complete with flags and models
            local flags="--license --modefile --parameters --system --template --verbose"
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            COMPREPLY=($(compgen -W "$flags $models" -- "$cur"))
            ;;
        stop)
            # For the `stop` command, complete with models from `ollama ps`
            local models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        *)
            # For other commands, complete with subcommands
            local subcommands="create pull run show stop serve start pull signin signout list ls ps help"
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            ;;
    esac

    # Sort and trim completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register completion function for ollama command
complete -F _ollama_completions ollama