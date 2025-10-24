#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this.
#
#First, the main goal is to make sure that when someone types `ollama run` followed by a model name and presses Tab, the shell suggests the available models correctly, even if those model names contain colons like `codellama:13b`.
#
#From the problem statement, I know that Bash's default behavior splits words on colons, which messes up the completion when a model has a colon in its name. So, I need to handle this by temporarily modifying `COMP_WORDBREAKS` so that the colon isn't treated as a word break.
#
#Let me outline the steps:
#
#1. **Function and Registration:** The script needs a function, say `_ollama_run_completions`, which is registered with `complete -F`. This function will handle all the completion logic for the `run` subcommand of ollama.
#
#2. **Subcommand Triggering:** I need to ensure that completion only activates when the second word (i.e., `COMP_WORDS[1]`) is exactly "run". So, inside the function, I'll check if `[[ "${COMP_WORDS[1]}" == "run" ]]`. If not, return early.
#
#3. **Handling Colons:** Since model names can have colons, which are treated as word breaks by Bash, I need to modify `COMP_WORDBREAKS` temporarily. The process is:
#   - Save the original value of `COMP_WORDBREAKS`.
#   - Remove the colon from it.
#   - Use `_get_comp_words_by_ref -n : cur prev` to re-parse the current and previous words without treating colons as word breaks.
#   - Restore the original `COMP_WORDBREAKS` immediately after.
#
#4. **Model Name Generation:** I need to fetch the list of models dynamically using `ollama list`. The output has a header line, so I'll skip that. Then, extract only the first column (model names) and use them as possible completions.
#
#Now, thinking about the code structure:
#
#- Inside the function, start by checking if the subcommand is 'run'.
#- If it's not, return.
#- Temporarily modify `COMP_WORDBREAKS` to remove colons. Remember to save the original value so I can restore it later.
#- Use `_get_comp_words_by_ref -n :` to re-parse the words with the new settings.
#- Fetch the model list using `ollama list`, skip the first line (header), and extract the first column.
#- Generate completions using `compgen` from these model names.
#
#Potential issues:
#
#- Forgetting to restore `COMP_WORDBREAKS` after modification could cause unexpected behavior in other completion functions. So, I must ensure it's restored properly.
#- Parsing the output of `ollama list` correctly is crucial. Using `awk '{print $1}'` should get the first column, and `tail -n +2` skips the header.
#
#Testing edge cases:
#
#- What if there are no models? The completion would return nothing, which is correct.
#- If a model name has multiple colons, like `model:part1:part2`, the modified `COMP_WORDBREAKS` should handle it correctly without breaking the words.
#
#Putting it all together, I'll write the function step by step, making sure each part works as intended and handles cases with colons properly. The comments in the code will explain each step for clarity.
#...done thinking.

_ollama_run_completions() {
    local cur prev

    # Temporarily modify COMP_WORDBREAKS to handle colons correctly
    local original_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS="$original_wordbreaks"

    # Only trigger for the 'run' subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Fetch available models from ollama list, skipping header
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # Generate completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

complete -F _ollama_run_completions ollama
