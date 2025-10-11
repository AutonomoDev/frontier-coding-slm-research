# Thinking...
# Okay, I need to create a Bash completion script for the `ollama run` command. The main issue is that model names can contain colons, which Bash treats as word breaks by default. This causes problems when trying to complete model names because the colon splits the word, making the completion logic incorrect.
#
# First, I should define a function named `_ollama_completions`. This function will handle completions for the `ollama` command. Inside this function, I need to check if the first argument is "run". If it's not, the function should return early because we only want to complete model names after `run`.
#
# Next, handling the colons correctly is crucial. By default, Bash uses `COMP_WORDBREAKS` which includes the colon as a word break character. This means that when a user types something like "codellama:", the current word becomes an empty string and the previous word is "codellama". To fix this, I need to temporarily modify `COMP_WORDBREAKS` by removing the colon.
#
# I'll save the original `COMP_WORDBREAKS` into a local variable so I can restore it later. Then, I'll remove the colon from this variable using parameter expansion. After modifying `COMP_WORDBREAKS`, I'll use `_get_comp_words_by_ref -n : cur prev` to re-parse the command line. This tells Bash not to split words on colons and correctly sets `cur` (current word) and `prev` (previous word).
#
# Once the parsing is done, I restore the original `COMP_WORDBREAKS` to avoid affecting other parts of the script or the shell environment.
#
# Now, if the previous word is "run", it's time to generate completions. I'll retrieve the model names by running `ollama list` and extracting the first column from each line after the header. Using `awk 'NR>1 {print $1}'`, I can get just the model names starting from the second line.
#
# With the list of models, I use `compgen -W "$models" -- "$cur"` to generate possible completions based on the current word being typed. This command filters the model names that match the current input and returns them as an array in `COMPREPLY`.
#
# Finally, I register the completion function with `complete -F _ollama_completions ollama`, ensuring that whenever a user runs `ollama` followed by a space, the completions are triggered.
#
# I need to make sure all steps are properly commented so others can understand why each part is necessary. Also, using local variables wherever possible will help prevent unintended side effects. I must avoid any syntax errors and ensure that the script works with `bash-completion` version 2 or later.
# ...done thinking.

_ollama_completions() {
    # Only handle completions for 'run' subcommand
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Save original word breaks and remove colon from them temporarily
    local original_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Reparse the command line with colons treated as part of words
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks immediately after re-parsing
    COMP_WORDBREAKS="$original_comp_wordbreaks"

    if [[ "$prev" == "run" ]]; then
        # Get list of available models from 'ollama list' command
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions based on current word and model names
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
