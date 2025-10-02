#Thinking...
#Okay, I need to create a robust Bash completion script for the `ollama run` command. The main challenge is handling model names that contain colons, which can break standard bash completion. Let me think through each requirement and how to implement them.
#
#First, the script must handle colons in model names correctly. I remember that by default, bash considers colons as word breaks, so when a user types something like `ollama run codellama:`, the colon would cause the completion to stop there. To fix this, I need to modify the `COMP_WORDBREAKS` variable temporarily. So, I'll save the original value, remove the colon, do the completion, and then restore it before exiting.
#
#Next, I need to determine when to trigger the completion. The script should only suggest models when the next word after "run" is being completed. That means I have to find the position of "run" in `COMP_WORDS` and check if `COMP_CWORD` is one position ahead. If not, the script shouldn't do anything.
#
#For parsing the model names, I need a reliable way to extract them from the output of `ollama list`. The correct approach is using `awk` to skip the header and get the first field, ensuring that any whitespace doesn't mess things up. I'll store these models in an array so they can be used for completion.
#
#I also need to handle cases where helper functions aren't available. So, I'll use `_get_comp_words_by_ref` if it's present; otherwise, I'll manually set `cur` and `prev` variables based on `COMP_WORDS`.
#
#When generating completions, using `compgen -W` with the models array is safer because it handles escaping properly and avoids issues with special characters. This way, I don't have to worry about regex messing things up.
#
#Another important point is ensuring that if no model matches, the script doesn't fall back to filename completion. So, I'll make sure `COMPREPLY` is empty in such cases and not register any default behavior.
#
#Putting it all together, I'll structure the function `_ollama_run_completions` to handle each of these steps. It will adjust `COMP_WORDBREAKS`, check for the correct position, parse models safely, and generate completions using the right methods. Finally, I'll make sure to register this function with `complete` so it triggers when `ollama run` is used.
#
#I think that covers all the requirements. Now, I'll write the script step by step, making sure each part is handled correctly.
#...done thinking.

# Bash completion script for ollama run command
# Handles model names containing colons and integrates with bash-completion framework v2

complete -F _ollama_run_completions ollama

function _ollama_run_completions {
    # Save original word break settings
    local old_wb="$COMP_WORDBREAKS"
    
    # Temporarily disable colon as word break to handle model names with colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Find the index of "run" in command words array
    local run_index=0
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done
    
    # Only trigger completion when next word after "run"
    if [[ $COMP_CWORD -ne $run_index + 1 ]]; then
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return
    }
    
    # Get current and previous words
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback if helper function not available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    # Extract model names from ollama list output, handling variable whitespace correctly
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
    
    # Generate completions safely using compgen to handle special characters
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Restore original word break settings before exit
    COMP_WORDBREAKS="$old_wb"
}

# Explanation:
# 1. The script first saves the original `COMP_WORDBREAKS` to prevent colon from breaking words.
# 2. It locates the "run" command in the current word list to determine when to trigger completions.
# 3. Extracts model names using safe parsing methods that handle variable whitespace and duplicate entries.
# 4. Uses `compgen -W` for safe completion generation instead of fragile regex matching.
# 5. Maintains proper behavior when no completions are found by leaving `COMPREPLY` empty.
# 6. Restores all settings to their original state before exiting.


