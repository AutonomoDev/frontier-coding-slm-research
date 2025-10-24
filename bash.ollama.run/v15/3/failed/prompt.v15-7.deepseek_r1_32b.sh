#!/usr/bin/env bash

#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this.
#
#First, the main goal is to have tab completion work correctly when using `ollama run`, especially since model names can contain colons, which are problematic by default in Bash completions because they're considered word breaks.
#
#So, the user wants a script that dynamically fetches the list of available models from `ollama list`. The output of this command includes model names like `codellama:13b`, so I need to parse that correctly.
#
#The critical points mentioned are important. Let's go through them one by one.
#
#1. **Function and Registration**: I'll create a function, say `_ollama_run_completions`, and register it with `complete -F`. That part seems straightforward.
#
#2. **Subcommand Triggering**: The completion should only activate when the second word is "run". So in the function, after handling colons, I need to check if `${COMP_WORDS[1]}` equals "run".
#
#3. **Correct Colon Handling**: This is tricky. By default, Bash splits words on colons, so when the user types `codellama:` and presses Tab, it doesn't recognize the colon as part of the word. To fix this, I need to modify `COMP_WORDBREAKS` temporarily.
#
#   The steps are:
#   - Save the original `COMP_WORDBREAKS`.
#   - Remove `:` from them.
#   - Use `_get_comp_words_by_ref -n : cur prev` to re-parse the current and previous words. This tells Bash not to split on colons.
#   - Restore the original `COMP_WORDBREAKS` immediately after.
#
#4. **Model Name Generation**: I'll run `ollama list`, parse its output to extract model names from the first column, skipping the header. Then use `compgen` to provide these as possible completions.
#
#Putting it all together:
#
#- The function starts by saving `COMP_WORDBREAKS`.
#- It removes `:` and re-parses the words.
#- Checks if the second word is "run".
#- Fetches model names using `ollama list`, processes them into an array.
#- Uses `compgen` to match against `cur` and sets `COMPREPLY`.
#
#I need to make sure that all these steps are correctly ordered. Especially, modifying `COMP_WORDBREAKS` must happen before the subcommand check.
#
#Potential issues: When restoring `COMP_WORDBREAKS`, using a temporary variable is essential. Also, ensuring that the parsing of `ollama list` output is robust—maybe it's better to use `awk` to extract the first column, skipping lines where the second field isn't a valid ID or something.
#
#Testing edge cases: What if there are no models? The script should handle that gracefully without errors.
#
#I think I've covered all points. Now, time to translate this into code.
#...done thinking.

_ollama_run_completions() {
    local cur prev words cword
    # Save the original word breaks
    local saved_wordbreaks="$COMP_WORDBREAKS"
    
    # Temporarily remove colon from word breaks to handle model names correctly
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev words cword
    COMP_WORDBREAKS="$saved_wordbreaks"

    # Only trigger completion for the 'run' subcommand
    if [[ "${words[1]}" != "run" ]]; then
        return 0
    fi

    # Fetch available models using ollama list and extract the first column (model names)
    local models=($(ollama list --no-color | tail -n +2 | awk '{print $1}'))
    
    # Generate completions from model names
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

# Register the completion function for ollama commands
complete -F _ollama_run_completions ollama
