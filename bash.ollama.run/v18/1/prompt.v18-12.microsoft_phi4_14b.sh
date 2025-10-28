_ollama_completions() {
    # Check if the command is `ollama run`
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    
    # Ensure we are completing only the model argument
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    local cur prev words cword

    # Extract current and previous word for colon handling
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of models from `ollama list`
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort the models alphabetically for better user experience
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate possible completions based on current input
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim colons if necessary to ensure correct completion behavior after colon input
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the function for autocomplete with ollama run command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation of Key Components:
# 
# 1. **Command Check**:
#    - The script first ensures that it only activates when `ollama run` is being used by checking `COMP_WORDS[0]` and `COMP_WORDS[1]`.
#    - It also verifies the cursor position (`COMP_CWORD`) to ensure we're completing the model argument specifically.
# 
# 2. **Colon Handling**:
#    - Utilizes `_get_comp_words_by_ref -n :` for proper handling of colons, enabling completions like `codellama:<TAB>` to work correctly.
#    - The function `__ltrim_colon_completions` is used after generating completions to adjust the input cursor position appropriately.
# 
# 3. **Model Parsing**:
#    - Retrieves the list of models using `ollama list`, parsing only relevant lines with `tail -n +2 | awk '{print $1}'`.
# 
# 4. **Sorting and Completions**:
#    - Models are sorted alphabetically for a more user-friendly completion experience.
#    - Uses `compgen` to generate possible completions from the sorted model list.
# 
# 5. **Edge Cases**:
#    - Handles scenarios where `ollama` might not be installed or no models exist gracefully by checking the command's existence and output before proceeding with parsing. 
# 
# This script efficiently provides auto-completions for the specified use case, adhering to best practices in Bash completion scripting.
