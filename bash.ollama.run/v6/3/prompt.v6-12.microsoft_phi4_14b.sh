# Define a function for ollama run command completion
_ollama_run_completion() {
    # Ensure COMP_WORDS and COMP_CWORD are set; they should be provided by bash-completion environment
    if [[ -n "${COMP_WORDS[*]}" && -n "$COMP_CWORD" ]]; then

        # Check if the first word is "ollama" and the previous word is "run"
        local prev_word="${COMP_WORDS[COMP_CWORD-1]}"
        if [[ "${COMP_WORDS[0]}" == "ollama" && "$prev_word" == "run" ]]; then
            # Get the current word being completed
            local cur="${COMP_WORDS[COMP_CWORD]}"

            # Retrieve and parse model names from ollama list output, skipping header line
            local models=($(ollama list | sed '1d' | awk '{print $1}' | sort -u))

            # Filter the model names based on the current word being typed (cur)
            COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
        fi
    fi
}

# Fallback to manual setting of cur and prev if _get_comp_words_by_ref is missing or fails
if ! type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref() {
        local cword="${COMP_CWORD}"
        local words=("${COMP_WORDS[@]}")
        eval "local -n comp_word=\${_GET_COMP_WORDS_REF_${cword}}"
        if [[ -z "${comp_word+x}" ]]; then
            for (( i = 0; i <= cword; i++ )); do
                eval "_GET_COMP_WORDS_REF_$i=\"\${words[$i]}\""
            done
            comp_word="${_GET_COMP_WORDS_REF_${cword}}"
        fi
    }
fi

# Register the completion function with bash-completion framework
complete -F _ollama_run_completion ollama
