# Bash completion for ollama run command with model name completion
# Usage: source this file or add to .bashrc with 'complete -F _ollama_completions ollama'

# Thinking...
# Okay, I need to create a bash completion script for the `ollama run` command that dynamically completes model names from `ollama list`. The problem is that model names can have colons, which Bash splits on by default, causing issues with word parsing. 
# 
# First, I should define a function called `_ollama_completions` as per the requirements. This function will handle the completions for the `ollama` command.
# 
# Inside the function, I need to check if the first argument after `ollama` is "run". If not, the function should exit early because we only want to complete for the `run` subcommand.
# 
# Next, handling colons in model names is crucial. By default, Bash treats colons as word breaks, which messes up the parsing of model names like `codellama:13b`. To fix this, I should temporarily remove the colon from `COMP_WORDBREAKS`. I'll save the original value to a variable, then modify it by removing all colons. After processing, I'll restore the original setting to avoid affecting other completions.
# 
# Using `_get_comp_words_by_ref` with `-n :` allows me to re-parse the command line without splitting on colons. This will correctly capture the model names as single words.
# 
# If the previous word is "run", I need to generate the list of models. I'll run `ollama list`, skip the header, and extract the first column using `awk`. Then, using `compgen -W`, I'll generate the possible completions based on the current word.
# 
# Finally, I'll register the function with `complete` so that Bash uses it for `ollama` commands. I need to ensure all variables are properly quoted to prevent word splitting and that the script is robust against errors.
# 
# Putting it all together, I structure the function step by step, adding comments where necessary to explain each part, especially the handling of colons in word breaks.
# ...done thinking.

function _ollama_completions {
    # Check if the subcommand is 'run'
    local cmd=${COMP_WORDS[1]}
    if [[ ${cmd} != "run" ]]; then
        return
    fi

    # Save original word break settings and remove colon to handle model names with colons properly
    local word_breaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Reparse the command line without treating colon as a word break
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word break settings
    COMP_WORDBREAKS=$word_breaks

    # If previous word is 'run', generate model name completions
    if [[ $prev == "run" ]]; then
        # Get list of models from ollama list command, excluding header row
        local models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Generate completions for the current word using the extracted model names
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama
