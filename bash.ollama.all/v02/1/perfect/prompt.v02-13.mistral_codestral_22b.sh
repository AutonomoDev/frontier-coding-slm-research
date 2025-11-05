# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for the `ollama` command line tool based on your requirements:

# Define the main completion function
_ollama_completions() {
    # Use a case statement to switch on subcommand
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ $cword == 1 ]]; then
        # If the previous word is 'ollama', provide a list of all subcommands as completions
        COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
    elif [[ $cword == 2 ]]; then
        # Handle special completion for different commands
        case ${words[1]} in
            show|run|stop|push|cp|rm)
                _ollama_model_completion
            ;;
            create)
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
            serve|pull|signin|signout|list|ps|help)
                # No argument completion for these commands, do nothing
                :
            ;;
        esac
    fi
}

# Define the model completion function (used by some subcommands)
_ollama_model_completion() {
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    # Fetch models, handle missing 'ollama' command and empty model list
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    # Generate completions, sort and trim
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script will provide tab completion for the `ollama` command line tool, including model name completion and special flag completion.
