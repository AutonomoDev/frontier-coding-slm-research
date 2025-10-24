#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which Bash treats as word breaks by default. This causes problems with completion because when someone types something like `codellama:`, Bash splits it into two words, making the previous word "codellama" and the current word empty. That's not good for completing the model name correctly.
#
#First, I remember that in Bash completions, the `_get_comp_words_by_ref` function can help re-parse the command line with custom word-breaking rules. So, I need to modify the `COMP_WORDBREAKS` variable temporarily to remove the colon so it doesn't split words there.
#
#I'll start by saving the original `COMP_WORDBREAKS` into a local variable. Then, I'll update `COMP_WORDBREAKS` to exclude the colon. Using `_get_comp_words_by_ref -n :` should re-parse the current and previous words without considering colons as word breaks. After that, I restore `COMP_WORDBREAKS` to its original value to prevent any side effects elsewhere.
#
#Next, I need to check if the previous word is "run" because we only want to complete model names after that subcommand. If it's "run", I'll retrieve the list of models using `ollama list | awk 'NR>1 {print $1}'` which skips the header and extracts the first column containing model names.
#
#Finally, I use `compgen -W "$models" -- "$cur"` to generate possible completions based on the current word being typed. This should correctly handle models with colons and provide accurate suggestions during completion.
#
#I'll structure all this into a function `_ollama_completions` and register it with `complete -F _ollama_completions ollama` so that Bash uses this function for completions when the command starts with `ollama`.
#...done thinking.

# bash_completion.sh

# Function to provide completion for 'ollama run' command
_ollama_completions() {
    # Check if we're completing the 'run' subcommand
    local cur prev words cword
    # Save original word breaks and modify to handle colons correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse command line with updated word breaks
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Restore original word breaks immediately to avoid side effects
    COMP_WORDBREAKS=${_old_wb}

    # Only complete model names after 'run'
    if [[ "${words[cword-1]}" == "run" ]]; then
        # Fetch list of available models from 'ollama list' output
        local models=$(ollama list | awk 'NR>1 {print $1}')
        # Generate completions based on current input
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function with the 'ollama' command
complete -F _ollama_completions ollama
