# Bash completion for ollama run <model> command
_ollama_run() {
    local cur prev models filtered sorted

    # If _get_comp_words_by_ref is defined, use it; otherwise, manually set 'cur' and 'prev' variables.
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref cur prev words cword
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Activate completion only when the previous word is 'run' and the command is 'ollama'.
    if [ "${prev}" != "run" ] || ! [[ ${COMP_LINE} =~ ^.*\s+ollama\s+$ ]]; then
        return
    fi

    # Run `ollama list` once and store output in a variable.
    models=$(ollama list 2>/dev/null)

    # If `ollama list` fails or returns empty, return without error and provide no completions.
    if [ $? -ne 0 ] || [ -z "$models" ]; then
        return
    fi

    # Filter model names that start with the current word being completed.
    filtered=()
    while IFS= read -r line; do
        [[ $line == "$cur"* ]] && filtered+=("$line")
    done <<< "$models"

    # Sort matching models alphabetically and assign to COMPREPLY.
    sorted=($(printf '%s\n' "${filtered[@]}" | sort))
    COMPREPLY=( "${sorted[@]}" )
}

# Wiring: Attach the function to `ollama` so that typing `ollama run <Tab>` triggers it.
complete -o default -F _ollama_run ollama
