# Bash completion script for ollama run command
_ollama_completions() {
    local cur prev matches sorted_matches
    if ! _get_comp_words_by_ref -n : cur prev; then
        compopt -o nospace
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list 2>/dev/null | awk 'NR > 1 && $0 !~ /^ *$/ {print $1}')
        declare -a model_list=($models)

        # If no models found, return empty COMPREPLY
        if [ ${#model_list[@]} -eq 0 ]; then
            COMPREPLY=()
            return
        fi

        # Create an array for matches starting with $cur
        local IFS=$'\n'
        matches=($(compgen -W "${model_list[*]}" -- "$cur"))
        sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

        COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
    fi

    # Ensure suggestions are trimmed correctly after colons
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
