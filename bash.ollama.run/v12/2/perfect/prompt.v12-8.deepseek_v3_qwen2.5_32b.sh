# ollama completion script

_ollama_completions() {
    # Only complete after 'ollama run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev || \
        { cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"; }

    if [[ $prev != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Ensure ollama command exists and parse its list output correctly
    command -v ollama &> /dev/null || {
        COMPREPLY=()
        return 0
    }

    local models=()
    while IFS= read -r line; do
        case $line in
            "NAME ID SIZE MODIFIED"|"")
                continue ;;
            *)
                local name=$(echo "$line" | awk '{print $1}')
                [[ -n $name ]] && models+=("$name") ;;
        esac
    done < <(ollama list 2>/dev/null)

    if (( ${#models[@]} == 0 )); then
        COMPREPLY=()
        return 0
    fi

    local matches=()
    for model in "${models[@]}"; do
        [[ $model == "$cur"* ]] && matches+=("$model")
    done

    # Sort the matches to make completion suggestions ordered
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
    
    # Critical: Handle colons properly, else no suggestions after colon (e.g., codellama:)
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
