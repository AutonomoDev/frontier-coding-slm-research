# [[HUMAN COMMENTED-OUT]]
#Here's a robust Bash completion script for `ollama run`:

_get_comp_words_by_ref() {
    local exclude cur prev words cword split
    if [[ $1 == -n ]]; then
        exclude=$2
        shift 2
    fi
    split=false
    for w in "${COMP_WORDS[@]}"; do
        if [[ ${w} == *=* ]]; then
            split=true
            break
        fi
    done
    if $split; then
        _get_comp_words_by_ref_split "$exclude" "$@"
    else
        _get_comp_words_by_ref_nosplit "$exclude" "$@"
    fi
}

# Finds the position of run in COMP_WORDS array.
_find_run() {
    local i=1
    while [[ $i -lt $COMP_CWORD ]]; do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            echo $((i+1))
            return 0
        fi
        ((i++))
    done
    echo 0
}

# Completion function for ollama run command.
_ollama_run() {
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word breaks

    local cur prev words cword run_index
    _get_comp_words_by_ref -n = cur prev words cword
    run_index=$(_find_run)

    if [[ $cword != $run_index ]]; then
        # We're not completing the 'run', so fall back to filename completion.
        COMPREPLY=()
    else
        # Get a list of models from "ollama list" command.
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
        # Generate completions for the current word.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi

    COMP_WORDBREAKS="$old_wb"  # Restore original word breaks.
    return 0
}
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#Please remember to source this script in your shell to activate the completions: `source /path/to/your/_ollama_run`.

