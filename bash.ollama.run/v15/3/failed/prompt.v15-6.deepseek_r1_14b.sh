#Thinking...
#Alright, I need to create a bash completion script for the `ollama run` command. Let me think through how to approach this.
#
#First, I know that the script should be a function named `_ollama_run_completions`. This function will handle the completion logic and needs to be registered with `complete -F _ollama_run_completions ollama`.
#
#The main challenge is handling model names that contain colons, like `codellama:13b`. By default, bash splits words on colons, which breaks the completion when the user types something like `ollama run codellama:` and presses Tab. So I need to modify `COMP_WORDBREAKS` temporarily to prevent this.
#
#The steps are:
#1. Save the original value of `COMP_WORDBREAKS`.
#2. Remove `:` from `COMP_WORDBREAKS` so that colons aren't treated as word breaks.
#3. Re-parse the words using `_get_comp_words_by_ref -n : cur prev` to correctly handle the model names.
#4. Restore the original `COMP_WORDBREAKS` after this.
#
#Next, I need to ensure that the completion only triggers for the `run` subcommand. The correct way is to check if the second word (`COMP_WORDS[1]`) is exactly "run". So inside the function, I'll add an if statement: `if [[ "${COMP_WORDS[1]}" != "run" ]]; then return 0; fi`.
#
#For generating model names dynamically, I'll run `ollama list` and parse its output. The first column contains the model names, so I'll skip the header line and extract each model name. Using `compgen -W` with these names will provide the suggestions.
#
#Putting it all together, the function will:
#- Temporarily adjust `COMP_WORDBREAKS`.
#- Check for the "run" subcommand.
#- Fetch and parse model names.
#- Use `compgen` to generate completions.
#
#I need to make sure that all this is done correctly within the function and that it's properly registered. Also, I should include comments in the script to explain each step clearly.
#...done thinking.

# Bash completion script for ollama run command
complete -F _ollama_run_completions ollama

function _ollama_run_completions {
    # Save original word break settings
    local save_wordbreaks="$COMP_WORDBREAKS"
    
    # Prevent colon from breaking words
    COMP_WORDBREAKS=
    
    # Get unbroken current and previous words
    _get_comp_words_by_ref -n : cur prev
    
    # Restore word break settings
    COMP_WORDBREAKS="$save_wordbreaks"
    
    # Only complete for 'run' subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    
    # Get list of models
    local models=$(ollama list | tail -n +2 | cut -d'|' -f1)
    
    # Generate completions for model names
    compgen -W "$models" -- "$cur"
}
