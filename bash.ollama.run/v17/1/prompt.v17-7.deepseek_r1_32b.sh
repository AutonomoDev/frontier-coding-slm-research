# Thinking...
# Okay, I'm trying to create a bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, like `codellama:13b`. From what I understand, the colon causes problems because it's treated as a word separator by Bash. So when someone types `ollama run codellama:` and presses Tab, Bash doesn't recognize it correctly.
# 
# I remember from previous attempts that modifying `COMP_WORDBREAKS` is necessary to handle this. Specifically, removing the colon from `COMP_WORDBREAKS` so that it's not treated as a separator anymore. But I also need to make sure that after processing, I restore the original value of `COMP_WORDBREAKS` to avoid affecting other completion functions.
# 
# So, here's what I think needs to be done step by step:
# 
# 1. **Check if the command is `ollama run`:** The function should only handle completions for `ollama run`. If the subcommand isn't `run`, it should exit immediately. This prevents interfering with other commands or falling back to filename completion.
# 
# 2. **Modify and restore `COMP_WORDBREAKS`:** Save the original value, remove the colon, then use `_get_comp_words_by_ref -n : cur prev` to parse the words correctly. After processing, restore the original `COMP_WORDBREAKS`.
# 
# 3. **Generate model list:** Check if `ollama` is available, then fetch the models using `ollama list`. The output has a header line, so I need to skip that and extract only the first column.
# 
# 4. **Handle completions after colon:** After generating the suggestions, use `__ltrim_colon_completions "$cur"` to ensure that when the user types a colon, the suggestions are displayed correctly without the colon being part of the model name.
# 
# 5. **Register the completion function:** Use `complete -F _ollama_completions ollama` so that Bash uses this function for completing `ollama` commands.
# 
# I also need to make sure that the code is structured correctly, with clear comments explaining each step, especially around the colon handling and context check. The script should be a single function without any markdown or explanations, just pure bash code with inline comments.
# 
# Wait, I'm not entirely sure about how `_get_comp_words_by_ref -n :` works. Does it parse the words using the colon as a delimiter? So when the user types `codellama:`, it correctly identifies `run` as the previous word and `codellama:` as the current word?
# 
# Also, I should make sure that after generating the completions with `compgen -W`, I call `__ltrim_colon_completions "$cur"` before returning. This step is crucial for displaying the suggestions correctly without including the colon in the output.
# 
# I think I've covered all the necessary parts, but let me double-check:
# 
# - Does the function exit early if not handling `run`?
# - Are `COMP_WORDBREAKS` modified and restored properly?
# - Is the model list generated correctly from `ollama list`, skipping headers?
# - Are completions handled both before and after a colon is entered?
# 
# Yes, I think that's all covered. Now, let me put this into code.
# ...done thinking.

# [[HUMAN COMMENTED-OUT]]
# To create a bash completion script for the `ollama run` command that handles model names with colons, follow these steps:
# 
# 1. **Check Command Context:** Ensure the function only processes `ollama run` commands and exits early if not.
# 
# 2. **Modify Word Breakers:** Temporarily remove the colon from `COMP_WORDBREAKS` to correctly parse words including those with colons.
# 
# 3. **Generate Model List:** Fetch models using `ollama list`, skipping headers, and extract model names.
# 
# 4. **Handle Completions After Colon:** Use `__ltrim_colon_completions` to ensure correct display of suggestions after a colon is entered.
# 
# 5. **Register Completion Function:** Register the function for use with the `ollama` command.
# 
# Here's the complete bash script implementing these steps:

_ollama_completions() {
    # Only handle 'run' subcommand
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS and modify it
    local OLD_COMP_WORDBREAKS=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Parse words correctly around colon
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS=$OLD_COMP_WORDBREAKS

    # Check if 'ollama' is available
    command -v ollama &>/dev/null || return 1

    # Fetch and parse model list
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Ensure correct display after colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script ensures that model names with colons are handled correctly, providing accurate completions both before and after a colon is entered.
