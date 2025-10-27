# Bash completion script for 'ollama run' command

# Thinking...
# Okay, so I'm trying to understand how to create a better bash completion script for the 'ollama run' command. The main issue is handling model names that have colons, like 'codellama:13b'. From what I gather, the colon causes problems because it's treated as a word separator by default in Bash.
# 
# In previous versions, v9 and v14, they tried to fix this but had some issues. V9 taught the core concept of modifying COMP_WORDBREAKS and using _get_comp_words_by_ref -n :, which got a 94% pass rate, but it didn't handle the display correctly because it missed __ltrim_colon_completions. So v14 added that function call but had some failures, possibly due to complexity.
# 
# Now, for v17, the plan is to merge the clarity of v9 with the completeness of v14 by simplifying and making sure both parts (parsing and display) are handled together. The key steps seem to be:
# 
# 1. Modify COMP_WORDBREAKS to remove the colon so that it's not treated as a word separator.
# 2. Use _get_comp_words_by_ref -n : to correctly parse the command line words.
# 3. After generating completions, call __ltrim_colon_completions to display them properly.
# 
# The script needs to start by checking if the command is 'ollama run' and exit immediately if not. Then implement the colon fix, fetch the model list using ollama list, generate completions with compgen, set COMPREPLY, and finally call __ltrim_colon_completions before ending.
# 
# I think I need to write a bash function _ollama_completions that does all this. Let me outline the steps:
# 
# - Check if COMP_WORDS[1] is 'run'; if not, return.
# - Save original COMP_WORDBREAKS.
# - Remove colon from it.
# - Get cur and prev with _get_comp_words_by_ref -n :.
# - Restore COMP_WORDBREAKS.
# - Check if ollama is installed; if not, return.
# - Fetch model list via ollama list and parse it using awk to get the first column after the header.
# - Use compgen to generate completions based on $cur.
# - Set COMPREPLY with these suggestions.
# - Call __ltrim_colon_completions "$cur" at the end.
# 
# I need to make sure all these steps are correctly implemented in the bash code. Also, include comments explaining each part for clarity.
# 
# Now, I'll structure this into a bash function step by step.
# ...done thinking.

# [[HUMAN COMMENTED-OUT]]
# To address the issue with model names containing colons in the 'ollama run' command's Bash completion script, we've designed a solution that ensures both correct parsing and proper display of completions. Here's the structured approach:
# 
# 1. **Function Definition and Initial Check**: The function `_ollama_completions` starts by verifying if the subcommand is 'run'. If not, it exits immediately to avoid interference with other commands.
# 
# 2. **Colon Handling**: Temporarily modify `COMP_WORDBREAKS` to remove the colon, allowing it to be treated as part of the model name. Use `_get_comp_words_by_ref -n :` to correctly parse the input and then restore `COMP_WORDBREAKS`.
# 
# 3. **Model List Retrieval**: Check if 'ollama' is installed. If not, exit. Fetch the list of models using `ollama list`, parse the output to extract model names, skipping the header.
# 
# 4. **Completion Generation**: Use `compgen` to generate completions based on the current word and store them in `COMPREPLY`.
# 
# 5. **Display Adjustment**: Call `__ltrim_colon_completions` to ensure suggestions are displayed correctly after a colon is typed.
# 
# Here's the bash code implementing these steps:

complete -F _ollama_completions ollama

function _ollama_completions() {
    # Check if the subcommand is 'run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS and remove colon to handle colons in model names
    local -r original_word_breaks="${COMP_WORDBREAKS}"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Reparse the command line with colon considered part of the word
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word breaks after parsing
    COMP_WORDBREAKS="${original_word_breaks}"

    # Ensure ollama is installed and available
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Retrieve and parse model names from 'ollama list' output
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions based on the current word
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Ensure correct display of completions after a colon is typed
    __ltrim_colon_completions "$cur"
}

# [[HUMAN COMMENTED-OUT]]
# This script ensures that model names with colons are handled correctly, providing accurate and properly displayed suggestions for the 'ollama run' command.
