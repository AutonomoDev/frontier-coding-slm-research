# This script provides autocompletion for the `ollama run` command
if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
fi

# Get the word being completed (current input)
cur="${COMP_WORDS[COMP_CWORD]}"

# Fetch the list of models from ollama list command
models=$(ollama list | awk 'NR>1 {print $1}')

# Generate possible completions based on the current input
completions=($(compgen -W "$models" -- "${cur}"))

# Set the completion results
COMPREPLY=( "${completions[@]}" )

