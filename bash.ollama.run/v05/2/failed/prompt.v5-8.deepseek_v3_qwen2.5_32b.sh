# Below is a Bash completion script for the 'ollama run' command.
# It provides autocompletion suggestions based on the output of 'ollama list'.

_ollama_run() {
    local cur prev words cword
    # Set up variables: cur (current word), prev (previous word)
    _get_comp_words_by_ref -n : cur prev words cword || return

    # Only complete after 'run' subcommand and no further arguments.
    if [[ ${words[cword-1]} == "run" && $cword -eq 2 ]]; then
        local models=()
        {
            ollama list |
            tail -n +2 |   # Skip the header line.
            cut -d ' ' -f1 |   # Extract first field (model names)
            while read -r model; do
                [[ "$model" =~ ^[a-zA-Z0-9\:\-]+$ ]] && models+=("$model")  # Basic validation.
            done
        }

        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

# Register the completion function for 'ollama run'
complete -F _ollama_run ollama

# End of script. To use, source this file in your shell session.
# Example: source my_script.sh

