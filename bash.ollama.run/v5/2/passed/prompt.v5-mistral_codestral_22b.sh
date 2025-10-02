_ollama_run () {
# Check if _get_comp_words_by_ref function is available
if type -t _get_comp_words_by_ref > /dev/null 2>&1; then
    _get_comp_words_by_ref cur prev words cword
else
    # Fallback: manually set 'cur' and 'prev' from COMP_WORDS/COMP_CWORD
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
fi

# Activate completion only for the word immediately following 'run' subcommand
if [[ ${prev} == "run" ]]; then

    # Get list of available model names
    models=($(ollama list | sed 1d | awk '{print $1}' | sort -u))

    # Filter based on the word being completed and add to COMPREPLY
    for model in "${models[@]}"; do
        if [[ ${model} == ${cur}* ]]; then
            COMPREPLY+=("${model}")
        fi
    done
fi
}
complete -F _ollama_run ollama

