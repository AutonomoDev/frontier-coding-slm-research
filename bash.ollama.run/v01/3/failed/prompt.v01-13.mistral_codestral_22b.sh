# Create a bash-completion function for `ollama run` command
_ollama_run() {
    local word models cmd
    COMPREPLY=()
    word="${COMP_WORDS[COMP_CWORD]}"

    # Run 'ollama list' and redirect stderr to /dev/null to suppress errors
    mapfile -t models < <(ollama list 2>/dev/null) || return 0

    COMPREPLY=( $(compgen -W "${models[*]}" -- "$word") )
}

# Register the completion function for `ollama run` command
complete -F _ollama_run ollama_run

# [[HUMAN COMMENTED-OUT]]
# To install and activate the script:
# 1. Save the above script to a file, e.g., `/etc/bash_completion.d/ollama_run`.
# 2. Source the file in your current shell session by running `source /etc/bash_completion.d/ollama_run`, or start a new terminal session for changes to take effect.
# 
# The completion function is now active and can be used immediately with the `ollama run` command.
