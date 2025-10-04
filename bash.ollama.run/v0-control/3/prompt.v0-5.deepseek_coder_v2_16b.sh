# ollama-run.bash

_ollama_run() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${prev} == "ollama" && ${COMP_CWORD} -eq 2 ]]; then
        # Get the list of models from `ollama list` output
        local models=$(ollama list | awk 'NR>1 {print $1}' | tr '\n' ' ')
        COMPREPLY=($(compgen -W "${models}" -- ${cur}))
    fi
}

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Snippet:
# Add the following line to your `.bashrc` or equivalent initialization file:

source /path/to/your/script/ollama-run.bash
