#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main issue is that model names contain colons, which can break standard bash completion because colons are often word separators.
#
#First, I'll start by understanding the requirements. The script must handle model names with colons correctly. That means when the user presses TAB after typing part of a model name, the completion should include options like `codellama:13b` without issues.
#
#Looking at the context, the models are listed using `ollama list`, and their names are in the first column. I need to extract these names properly. Using `awk` seems better than `cut` because it's more robust against varying whitespace. So, I'll use `awk 'NR>1 {print $1}'` to get the model names starting from the second line.
#
#Next, handling the colons in bash completion is crucial. By default, bash considers colons as word break characters, which would split the model name into parts. To fix this, I need to temporarily remove the colon from `COMP_WORDBREAKS`. I'll save the original value, modify it, and restore it after processing to avoid side effects.
#
#Position detection is another important part. The completion should trigger only when the user is typing the argument for `run`, which is the model name. So, I need to find where "run" appears in `COMP_WORDS` and ensure that the current word (`COMP_CWORD`) is exactly after it. This way, the completion doesn't activate at the wrong time.
#
#I'll use a helper function `_get_comp_words_by_ref` to handle the extraction of current and previous words. If this function isn't available (which can happen in some environments), I'll manually set `cur` and `prev` as fallbacks.
#
#For filtering, using `compgen -W "$models" -- "$cur"` is safer than regex because it avoids special characters causing issues. This ensures that only the models starting with the current input are suggested.
#
#Finally, the script shouldn't fall back to filename completion, so I'll clear `COMPREPLY` when no matches are found. Also, registering the completion function without `-o default` ensures this behavior.
#
#Putting it all together, I structure the script step by step: saving word breaks, extracting model names, handling position and current input, generating completions safely, and restoring everything properly to maintain stability.
#...done thinking.

# Bash completion script for ollama run command
# Handles model names with colons (e.g., codellama:13b)

# Save the original word breaks
local old_wb="$COMP_WORDBREAKS"

# Remove colon from word breaks to handle model names correctly
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

# Extract list of available models, skipping header and avoiding duplicates
models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

# Restore word breaks immediately after extraction
COMP_WORDBREAKS="$old_wb"

# Find the index of "run" in COMP_WORDS
local run_index=-1
for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
        run_index=$i
        break
    fi
done

# Only proceed if we found "run" and current word is right after it
if [[ $run_index != -1 && $((run_index + 1)) == "$COMP_CWORD" ]]; then
    # Extract current input being typed
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Generate completion matches using prefix matching
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Clear COMPREPLY if no matches found
    if [[ ${#COMPREPLY[@]} == 0 ]]; then
        COMPREPLY=()
    fi
fi

# Restore word breaks before returning
COMP_WORDBREAKS="$old_wb"

