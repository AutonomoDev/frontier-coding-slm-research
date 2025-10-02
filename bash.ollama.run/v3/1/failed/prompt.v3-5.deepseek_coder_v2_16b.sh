# Bash completion for ollama run <model>
_ollama_run_complete() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur:prev:words:cword
    if [[ ${cword} -ne 2 || "${prev}" != "run" ]]; then
        return
    fi

    # Retrieve the list of models using ollama list
    local model_list=$(ollama list 2>/dev/null)
    if [ -z "$model_list" ]; then
        return
    fi

    # Filter models by the current word being completed
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    for model in $model_list; do
        [[ $model == "$cur"* ]] && COMPREPLY+=("$model")
    done

    # Sort the completions alphabetically
    printf -v sorted_completions '%s\n' "${COMPREPLY[@]}"
    IFS=$'\n'; sorted_completions=($(sort <<<"$sorted_completions")); unset IFS
    COMPREPLY=("${sorted_completions[@]}")
}

# Attach the completion function to ollama run
complete -F _ollama_run_complete ollama run
