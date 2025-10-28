_ollama_completions() {
    # Check if the command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    
    # Ensure we're completing the second argument
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev words cword models
    
    # Use _get_comp_words_by_ref if available for handling colons in completion
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Retrieve and parse the list of models from 'ollama list' if available
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    else
        return 0
    fi

    # Sort the model names alphabetically
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
    
    # Generate completion suggestions based on current input and available models
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim colons from the completion if necessary, using __ltrim_colon_completions
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for 'ollama run'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 
# 1. **Command Verification**: The script first checks if it is being triggered by `ollama run` using an index check on `COMP_WORDS`. If not, it exits early.
# 
# 2. **Argument Position Check**: It ensures the completion process occurs at the second argument position (`COMP_CWORD -ne 2`). This prevents interference with other parts of potential command input.
# 
# 3. **Handling Colons**:
#    - Uses `_get_comp_words_by_ref` if available to handle situations where colons are used in arguments (e.g., `model:version`).
#    - Sets `cur` and `prev` based on the current context, which helps in understanding what part of the input is being completed.
# 
# 4. **Model Retrieval**:
#    - Executes `ollama list`, processing its output to get a list of model names using `tail` and `awk`.
#    - Handles cases where `ollama` might not be installed or available by checking with `command -v`.
# 
# 5. **Sorting**:
#    - The script sorts the models alphabetically before generating completions, ensuring users see an organized list.
# 
# 6. **Completion Generation**:
#    - Uses `compgen` to match the current input (`$cur`) against available models.
#    - Generates potential completions without additional filtering or looping logic, reducing bugs and improving efficiency.
# 
# 7. **Colon Handling Fix**:
#    - If colons are involved in completion (e.g., partial inputs like `codellama:`), it trims them appropriately using `__ltrim_colon_completions`.
# 
# 8. **Registration**: The script concludes by registering the function with Bash's completion system for the `ollama run` command.
# 
# This structured approach ensures robust, efficient, and error-free completion behavior tailored to user input scenarios involving model names and optional version specifiers.
