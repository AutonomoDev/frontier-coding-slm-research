# Check if _get_comp_words_by_ref exists, otherwise define it as no-op
type _get_comp_words_by_ref > /dev/null 2>&1 || _get_comp_words_by_ref() { return 0; }

_ollama()
{
    local cur prev models model
    _get_comp_words_by_ref -n : cur prev

    # Activate only after `run`
    if [[ $prev != "run" ]] || [[ ${COMP_WORDS[1]} != "ollama" ]]; then
        return 0
    fi

    # Get list of models, handle failure gracefully
    models=$({ ollama list; } 2>/dev/null)
    [[ -z $models ]] && return 0

    # Filter and sort model names based on current word
    while IFS= read -r model; do
        [[ $model == "$cur"* ]] && comp+=("$model")
    done <<< "$models"
    compgen -W "${comp[*]}" -- "$cur"
}
complete -o default -F _ollama ollama

