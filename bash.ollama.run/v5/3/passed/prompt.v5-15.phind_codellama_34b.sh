# Bash completion for the `ollama run` command.
# Requires: bash-completion v2 framework (typically provided by 'bash-completion' package on Linux systems).

_ollama_run_completions() {
    # Only attempt to complete if the first word is "ollama" and the second word is "run".
    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Obtain a list of model names from 'ollama list', excluding the header.
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Extract the current word being completed.
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate completion suggestions based on matching model names.
    COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
}
complete -F _ollama_run_completions ollama

