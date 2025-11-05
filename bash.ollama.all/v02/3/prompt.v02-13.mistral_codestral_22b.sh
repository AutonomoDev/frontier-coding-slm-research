# [[HUMAN COMMENTED-OUT]]
# Here's a Bash function that generates tab completions for the `ollama` command line tool based on your specifications:

# Define the main completion function for ollama
_ollama_completions() {
    local cur prev words cword
    _init_completion || return

    case $prev in
        # Commands requiring `<MODEL>` completion
        show|run|stop|push|cp|rm)
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur";;
        # Command with special flag completion
        create)
            local flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"));;
        # Commands with no argument completion
        serve|pull|signin|signout|list|ps|help)
            return;;
    esac
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script defines a Bash function `_ollama_completions` that handles tab completion for the `ollama` command line tool. It uses a case statement to switch on the subcommand and provide the appropriate completions. The function follows your specifications, including the exact implementation of model name completion.
