# bash-completion for `ollama run <model>`
_ollama_run_complete() {
    # get current and previous words
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # only complete after `ollama run`
    [[ $prev != run ]] && return

    # retrieve model list once; bail on error or empty
    models_output=$(ollama list 2>/dev/null) || return
    [[ -z $models_output ]] && return

    # load into array
    models=()
    while IFS= read -r model; do
        models+=("$model")
    done <<< "$models_output"

    # sort alphabetically
    IFS=$'\n' sorted=($(printf '%s\n' "${models[@]}" | sort))

    # generate completions matching prefix
    COMPREPLY=( $(compgen -W "${sorted[*]}" -- "$cur") )
}

# wire-up for `ollama`
complete -F _ollama_run_complete ollama

# Installation:
# 1. Save this to ~/.bash_completion.d/ollama
# 2. Add to ~/.bashrc:  source ~/.bash_completion.d/ollama
# 3. Reload now:       source ~/.bashrc

