# [[HUMAN COMMENTED-OUT]]
# ```bash
_ollama_completions() {
    # Only activate for 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev models=()
    
    # Handle colons
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Fetch models from 'ollama list'
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort models for completion
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS
    
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    # Trim colons if present
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion for 'ollama'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 1. **Index Check**: The function checks if the command starts with `ollama run` and ensures that completions are only triggered when the third word is being entered (`$COMP_CWORD == 2`).
# 2. **Colon Handling**: Uses `_get_comp_words_by_ref -n :` to handle colon-separated input correctly, setting `cur` properly even if part of a completion (e.g., `codellama:13b` becomes `codellama:` in `cur`).
# 3. **Model Parsing**: Fetches model names from `ollama list`, skipping the header with `tail -n +2 | awk '{print $1}'`.
# 4. **Sorting and Completion**: Models are sorted before generating completions, ensuring a clean alphabetical order.
# 5. **Colon Trimming**: Ensures that colons are properly handled in the completion input/output.
# 
# This script should work seamlessly for any valid model name format (including those with colons), providing accurate completions as expected.
