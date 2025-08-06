# Store ollama completions
_ollama() {
    # Handle missing _get_comp_words_by_ref
    local cur prev words cword
    if declare -F _get_comp_words_by_ref > /dev/null; then
        _get_comp_words_by_ref cur prev words cword
    else
        # Fallback to manual parsing of COMP_WORDS and COMP_CWORD
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Activate completion only if previous word is 'run'
    if [[ $prev == "run" ]]; then
        local -a models=()
        # Run ollama list once and store output
        local olla_list
        olla_list=$(ollama list 2>/dev/null || true)
        while IFS= read -r line; do
            if [[ $line == "$cur"* ]]; then
                models+=("$line")
            fi
        done <<< "$olla_list"

        # Sort and assign to COMPREPLY
        COMPREPLY=( $(printf "%s\n" "${models[@]}" | sort) )
    fi
}
# Attach function to ollama for run completions
complete -F _ollama ollama
