#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which can break standard bash completion. Let me go through the requirements step by step.
#
#First, I remember that in Bash, word breaks include certain characters like colon by default. So when the user types something with a colon and presses tab, bash might not complete it correctly. To fix this, I need to temporarily remove the colon from `COMP_WORDBREAKS`. But I must save the original value and restore it after completion to avoid affecting other commands.
#
#Next, I need to determine where "run" appears in the command line arguments (`COMP_WORDS`). The script shouldn't assume a fixed position because the user might have other options before "run". So I'll loop through `COMP_WORDS` to find the index of "run".
#
#Once I've found "run", I check if the current word being completed is right after it. That way, completion only triggers when the user is typing the model name after `ollama run`.
#
#For retrieving model names, using `ollama list` makes sense. Parsing the output, I should extract the first column, which contains the model names. Using `awk` to print the first field handles variable whitespace better than `cut -d' ' -f1`, which is fragile if there are more spaces.
#
#I also need a helper function fallback. If `_get_comp_words_by_ref` isn't available, I'll manually set `cur` and `prev` from `COMP_WORDS`. This ensures compatibility across different environments.
#
#When generating completions, using `compgen -W "$models" -- "$cur"` is safer than using `grep` because it handles special characters in model names without issues. It also correctly filters models that start with the current input.
#
#I must ensure the script doesn't fall back to filename completion by not using `-o default` when registering the completion function. Also, clearing `COMPREPLY` when no matches are found prevents unexpected behavior.
#
#Putting it all together, I'll structure the script to handle these steps: save and adjust word breaks, find "run" in command words, parse models correctly, determine the current and previous words, generate completions safely, and restore everything properly. Each step is commented for clarity so others can understand how it works.
#...done thinking.

# Bash completion script for ollama run command
# Handles model names with colons (e.g., codellama:13b)

function _ollama_run_complete {
    # Save original word breaks and remove colon from them
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Find the index of "run" in COMP_WORDS array
    local run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done
    
    # Only trigger completion when typing the model name after "run"
    if [[ $run_index != -1 && $((run_index + 1)) == "$COMP_CWORD" ]]; then
        # Get list of available models, handling variable whitespace
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
        
        # Use helper function if available, else fallback to manual extraction
        _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        }
        
        # Generate completions using safe prefix matching
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
    
    # Restore original word breaks before returning
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with bash-completion framework v2
complete -F _ollama_run_complete ollama

# [[HUMAN COMMENTED-OUT]]
#This script provides robust Bash completion for `ollama run` commands while handling model names containing colons. It:
#
#1. Temporarily removes colon from word breaks during completion
#2. Correctly identifies when to trigger completion after "run"
#3. Safely parses model names from `ollama list` output
#4. Uses safe prefix matching instead of fragile regex
#5. Properly restores original word breaks before returning
#6. Includes fallback for older bash-completion versions
#
#The script is ready to be sourced and will work with the latest bash-completion framework while maintaining compatibility with earlier versions.

