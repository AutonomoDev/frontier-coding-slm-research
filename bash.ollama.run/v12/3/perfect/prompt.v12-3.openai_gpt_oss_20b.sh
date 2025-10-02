#Thinking...
#We need to output pure bash code that defines _ollama_completions, follows all steps.
#
#We must not add any text outside code, no markdown.
#
#Let's write:
#
#```
## Bash completion for ollama run
#
#_ollama_completions() {
#    local cur prev
#
#    # Use bash-completion's word parsing if available, ignoring ':' as a separator
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Ensure we are completing after "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Verify ollama command exists
#    if ! command -v ollama &>/dev/null; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Retrieve model names from ollama list
#    local models=()
#    while IFS= read -r line; do
#        # Skip header and empty lines
#        if [[ -z "$line" || "$line" == NAME* ]]; then
#            continue
#        fi
#        local name
#        name=$(echo "$line" | awk '{print $1}')
#        if [[ -n "$name" ]]; then
#            models+=("$name")
#        fi
#    done < <(ollama list 2>/dev/null)
#
#    # If no models found, no completions
#    if [[ ${#models[@]} -eq 0 ]]; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Find matches starting with current word
#    local matches=()
#    for m in "${models[@]}"; do
#        if [[ $m == $cur* ]]; then
#            matches+=("$m")
#        fi
#    done
#
#    # Sort matches
#    local sorted_matches
#    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#
#    # Generate COMPREPLY
#    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
#
#    # Trim colons so that completions appear after a colon
#    __ltrim_colon_completions "$cur"
#}
#
## Register the completion function
#complete -F _ollama_completions ollama
#```
#
#Need to ensure `__ltrim_colon_completions` is called after COMPREPLY assignment. Good.
#
#Also comment about ignoring colon.
#
#We should ensure we use local for all variables.
#
#Also need to consider that compgen output should be quoted properly. In assignment, use `COMPREPLY=($(compgen ...))`. This is fine.
#
#Ok final code.
#...done thinking.

# Bash completion for ollama run
_ollama_completions() {
    local cur prev

    # Try to use bash-completion's advanced word parsing that ignores ':' as a separator.
    # This ensures that typing "codellama:" keeps the ':' with the word instead of splitting.
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback if the helper function isn't available.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Ensure the ollama command exists before trying to list models.
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Gather model names from `ollama list`. Skip header and empty lines.
    local models=()
    while IFS= read -r line; do
        # Skip the header row and any empty lines.
        if [[ -z "$line" || "$line" == NAME* ]]; then
            continue
        fi
        # Extract only the first column (the model name).
        local name
        name=$(echo "$line" | awk '{print $1}')
        [[ -n $name ]] && models+=("$name")
    done < <(ollama list 2>/dev/null)

    # If no models were found, don't offer completions.
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matches that start with the current word.
    local matches=()
    for m in "${models[@]}"; do
        if [[ $m == $cur* ]]; then
            matches+=("$m")
        fi
    done

    # Sort matches to provide orderly suggestions.
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Build the COMPREPLY array using compgen.
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Remove any leading ':' from the completions so that suggestions appear correctly
    # after a typed colon, e.g., "codellama:".
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completions ollama

