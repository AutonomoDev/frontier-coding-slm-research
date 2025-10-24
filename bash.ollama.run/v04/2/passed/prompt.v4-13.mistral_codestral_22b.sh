# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for `ollama run` command following all the requirements mentioned:

# /etc/bash_completion.d/ollama

_ollama() {
    local cur prev words cword
    _init_completion -n : || return

    # Get the word after 'ollama' (the subcommand)
    case $prev in
        run)
            COMPREPLY=($(compgen -W "$(_get_models)" -- ${cur}))
            return 0
            ;;
        *)
            ;;
    esac
} && complete -F _ollama ollama

# Function to get available local models
_get_models() {
    local output
    # Run the command and store its output, skipping the header line.
    output=$(ollama list | awk 'NR>1{print $1}')

    echo "$output"
}

# [[HUMAN COMMENTED-OUT]]
#This script first initializes Bash completion for `ollama`. It then checks if the previous word was `run`. If so, it calls the `_get_models` function to get available local models. These models are used as possible completions and stored in `COMPREPLY`, which is the array that contains the list of words to complete.
#
#The `_get_models` function runs the command `ollama list` and pipes its output to `awk`. The `NR>1` condition in `awk` skips the header line, and `print $1` prints only the first column (the model names). These names are then echoed back into the completion suggestion.

