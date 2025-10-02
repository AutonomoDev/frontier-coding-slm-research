#Thinking...
#Okay, I need to create a robust Bash completion script for the `ollama run` command. The main issue is that model names can contain colons, which break standard bash completion. Let's see how I can approach this.
#
#First, from the context, I know that the completion should work with bash-completion framework v2. So I'll need to write a function that follows their guidelines.
#
#The task mentions several critical requirements. Let me go through them one by one.
#
#1. **Colon Handling**: This is the most important part. Colons in model names cause issues because they are considered word breakers in Bash. The solution here is to temporarily remove the colon from COMP_WORDBREAKS, perform the completion, and then restore it. I'll make sure to save the original value before modifying it and restore it after.
#
#2. **Position Detection**: I need to find where "run" is in COMP_WORDS. Only when the current word is right after "run" should the completion trigger. So I'll loop through COMP_WORDS to find the index of "run". If it's not found, or if the current word isn't next, I won't provide any completions.
#
#3. **Robust Data Parsing**: The sample output from `ollama list` shows that model names are in the first column but may have varying whitespace. Using `awk` to extract the first field after skipping the header is reliable. I should avoid using fragile methods like `cut -d' ' -f1` because it might not handle all cases correctly.
#
#4. **Helper Function Fallback**: The function `_get_comp_words_by_ref` helps get variables like cur and prev. But if it's unavailable, I'll need to manually set them by accessing COMP_WORDS directly.
#
#5. **Safe Filtering**: Using `compgen -W` with the models list is safer than using `grep`, especially because model names might have special characters that could break regex.
#
#6. **No Filename Fallback**: The completion should only trigger for `ollama run`. I'll make sure to register it without any default fallback, so if there are no matches, nothing happens.
#
#Putting this all together, the function `_ollama_run_completions` needs to:
#
#- Check if the current command is part of an `ollama run` invocation.
#- Extract model names correctly, ignoring colons in word breaks.
#- Provide completions only when appropriate.
#
#I'll start by checking if the previous word is "run". Then, I'll get all model names using `ollama list`, extract just the first column, and handle any errors by redirecting stderr to /dev/null.
#
#Next, I'll use `_get_comp_words_by_ref` to get cur and prev. If that fails, I'll parse them from COMP_WORDS manually.
#
#Then, I'll generate completions using `compgen -W`, which safely matches the current word against the models. This ensures that partial model names are correctly completed, even if they contain colons.
#
#I'll make sure to reset COMP_WORDBREAKS after processing to avoid affecting other completion scripts.
#
#Finally, I'll register this function with `complete` so that it triggers for `ollama run`.
#
#Testing the examples given should ensure it works as expected. For instance, when typing `ollama run <TAB>`, all models appear. If part of the model name is typed, like `code<TAB>`, only matching models are shown.
#
#I think I've covered all the points and followed each requirement carefully. Now, putting this into a bash script with clear comments.
#...done thinking.

# Bash Completion Script for ollama run command

# Function to handle completions for 'ollama run'
function _ollama_run_completions {
    # Save original word break settings
    local old_wb="$COMP_WORDBREAKS"

    # Temporarily remove colon from word break characters
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get the index of "run" in COMP_WORDS array
    local run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete when current word is after 'run'
    if [[ "$run_index" != -1 && "$COMP_CWORD" == "$run_index + 1" ]]; then
        # Extract model names from ollama list output, skipping header
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

        # Get current and previous words using helper function; fall back to manual parsing if needed
        _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        }

        # Generate completions for models matching the current word (cur)
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # No completion provided if not in 'ollama run' context
        COMPREPLY=()
    fi

    # Restore original word break settings
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function for ollama command
complete -F _ollama_run_completions ollama

