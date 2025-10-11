# This is a self-contained Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names.

_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n :cur: -n :prev: -n :words: -n :cword:
    
    # Ensure the first word is `ollama` and the previous word is `run`.
    if [[ "${words[0]}" != "ollama" || "${prev}" != "run" ]]; then
        return 1
    fi

    # Get the list of available local models.
    local models=$(ollama list | tail -n +2 | cut -d' ' -f1)

    # Generate completion suggestions based on the current word being typed.
    COMPREPLY=()
    for model in $models; do
        if [[ "${model}" == "${cur}*" ]]; then
            COMPREPLY+=("$model")
        fi
    done

    # Ensure no duplicate entries are included.
    COMPREPLY=$(echo "$COMPREPLY" | tr ' ' '\n' | sort -u | tr '\n' ' ')
}

complete -F _ollama_run_completion ollama run


