# Thinking...
# Okay, I need to create a robust Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which cause problems because Bash splits on them by default. 
# 
# First, I'll define a function called `_ollama_completions`. This function will handle the completions for the `ollama` command. Inside this function, I should check if the subcommand is "run". If not, the function should exit early.
# 
# Next, to deal with colons in model names, I need to temporarily modify `COMP_WORDBREAKS` so that colons aren't treated as word breaks. I'll save the original value, remove the colon, then reparse the command line using `_get_comp_words_by_ref -n : cur prev`. After processing, I must restore the original `COMP_WORDBREAKS`.
# 
# If the previous word is "run", I'll generate completions by running `ollama list` and extracting the model names. Using `awk`, I can skip the header and print the first column. Then, using `compgen -W`, I'll match the current word against these models.
# 
# Finally, I'll register the completion function with `complete -F _ollama_completions ollama` so that it's used when typing `ollama run`.
# 
# I need to make sure all steps are correctly implemented and commented for clarity. Also, I should avoid any global changes to `COMP_WORDBREAKS` by restoring it immediately after use.
# ...done thinking.

# Bash completion script for ollama run command with colon-safe model name handling

# Save original word break characters
local old_word_breaks="$COMP_WORDBREAKS"

# Temporarily remove ':' from word breaks to handle model names correctly
COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

# Reparse command line without treating colons as word breaks
_get_comp_words_by_ref -n : cur prev

# Restore original word break characters
COMP_WORDBREAKS="$old_word_breaks"

# If the previous word is "run", provide model name completions
if [[ "$prev" == "run" ]]; then
    # Get list of available models from ollama list command, excluding header row
    local models=$(ollama list | awk 'NR>1 {print $1}')
    
    # Generate completions for the current word against model names
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
fi

# Register completion function for ollama command
complete -F _ollama_completions ollama
