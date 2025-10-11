# Thinking...
# Alright, I need to create a robust Bash completion script for the `ollama run` command. The main goal is to dynamically complete model names that include colons without breaking due to Bash's default word-splitting on colons.
#
# First, I'll start by defining the function `_ollama_completions`. This function will handle completions specifically for the `ollama` command. Inside this function, I need to check if the first argument after `ollama` is "run". If it isn't, I should return early to avoid unnecessary processing.
#
# Next, handling colons correctly is crucial. By default, Bash treats colons as word breaks, which messes up the parsing of model names like `codellama:13b`. To fix this, I'll temporarily modify `COMP_WORDBREAKS` by removing the colon. But I must remember to save the original value so I can restore it later. Using parameter expansion, I can replace all colons in `COMP_WORDBREAKS` with an empty string.
#
# After modifying `COMP_WORDBREAKS`, I'll use `_get_comp_words_by_ref -n : cur prev` to re-parse the command line. The `-n :` option tells Bash not to split words on colons, ensuring that model names are correctly captured in `cur` and `prev`.
#
# Once the parsing is done, I'll restore the original `COMP_WORDBREAKS` immediately to prevent any side effects elsewhere.
#
# Now, if the previous word (`prev`) is "run", it's time to generate completions. I'll retrieve the list of models by running `ollama list` and extracting the first column from lines after the header using `awk 'NR>1 {print $1}'`. This gives me all model names.
#
# Finally, I'll use `compgen -W "$models" -- "$cur"` to generate possible completions based on the current word being typed. The results are stored in `COMPREPLY`, which Bash uses to display the suggestions.
#
# I also need to ensure that the script is registered with `complete -F _ollama_completions ollama` so that the completion function is called whenever the user types `ollama`.
#
# Throughout this process, I'll add detailed inline comments to explain each step, especially the part about modifying `COMP_WORDBREAKS`. This helps anyone reading the script understand why those steps are necessary.
#
# I must be careful with variable quoting to prevent word splitting and ensure that all commands are correctly parsed. Also, using local variables where possible keeps the script clean and avoids conflicts.
#
# Testing each part step by step would help catch any issues early, like ensuring that model names with colons are correctly handled and that the function doesn't interfere with other completions or commands.
#
# Overall, the key points are: checking for the "run" subcommand, modifying `COMP_WORDBREAKS` temporarily, re-parsing the command line correctly, fetching model names dynamically, and generating the appropriate completions. By following these steps carefully, I can create a reliable completion script that enhances the user experience when working with the `ollama run` command.
# ...done thinking.

# Bash completion script for ollama run command
_ollama_completions() {
    # Only complete for 'run' subcommand
    local command="${COMP_WORDS[1]}"
    if [[ "$command" != "run" ]]; then
        return
    fi

    # Save original word breaks and remove colon from them
    local original_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Reparse command line with colons not treated as word breaks
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks immediately after re-parsing
    COMP_WORDBREAKS="$original_comp_wordbreaks"

    if [[ "$prev" == "run" ]]; then
        # Fetch list of models from ollama list command
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions based on current word
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register completion function with bash-completion
complete -F _ollama_completions ollama
