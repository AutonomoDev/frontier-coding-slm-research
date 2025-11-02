# Thinking...
# Alright, I need to create a bash-completion function for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list` without using any external dependencies.
# 
# First, I should understand how bash completions work. Typically, a completion function is added to the shell's configuration files, like `.bashrc` or `.bash_profile`, and it uses variables like COMP_WORDS and COMP_CWORD to determine what has been typed so far. The function then generates possible completions and sets them in COMPREPLY.
# 
# So, for `ollama run <Tab>`, when the user presses Tab after typing `run `, the completion should suggest model names from `ollama list`. 
# 
# I need to capture the output of `ollama list` which prints model names one per line. I'll have to split this output into an array where each element is a model name.
# 
# Next, I should handle cases where `ollama list` might fail, such as if the command isn't found or there's an error. In that case, the completion shouldn't break but just return no suggestions.
# 
# I remember that bash has built-in commands for string manipulation and array handling. So, instead of using external tools like jq, I'll use `read -r` to read lines into an array.
# 
# The structure will be:
# 
# 1. Check if the command starts with `ollama run`.
# 2. Capture the current word being completed (COMP_WORDS[COMP_CWORD]).
# 3. Fetch the list of models by running `ollama list`, redirecting errors to /dev/null to prevent issues.
# 4. If `ollama list` fails, return without suggesting anything.
# 5. Split the output into an array, trimming any whitespace.
# 6. Use a case-insensitive match to filter model names that start with the current word prefix.
# 7. Assign these matches to COMPREPLY.
# 
# I should also make sure the script is minimal and robust, avoiding unnecessary commands or dependencies. Finally, provide clear installation instructions on how to add this completion function to the user's bash setup.
# 
# Putting it all together, I'll write a function that checks the command, fetches models, filters them based on the current input, and handles any potential errors gracefully.
# ...done thinking.

# Bash completion for ollama run command
_ollama_run() {
    local cur_model cword words
    COMPREPLY=()
    
    # Only trigger when completing "ollama run"
    if [[ ${COMP_WORDS[0]} != "ollama" ]] || (( COMP_CWORD < 2 )) || [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    cword="${COMP_WORDS[COMP_CWORD]}"
    
    # Fetch list of models, ignore errors
    models=$(ollama list 2>/dev/null | tr '\n' ' ')
    if [ -z "$models" ]; then
        return
    fi
    
    # Split into array and trim whitespace
    read -r -a words <<< "$models"
    
    # Match models starting with current word (case-insensitive)
    for model in "${words[@]}"; do
        model=$(echo "$model" | xargs)  # Trim any surrounding whitespace
        if [[ "$model" = $cword* ]]; then
            COMPREPLY+=("$model")
        fi
    done
}

# Register completion function
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 1. Save this script to your home directory as `~/.bash_completion_ollama`
# 2. Add the following line to your `~/.bashrc` or `~/.bash_profile`:
#    source ~/.bash_completion_ollama
# 3. Apply changes immediately by running:
#    source ~/.bashrc
# 
# This script provides completion for `ollama run <Tab>` by listing available models from `ollama list`, handling errors gracefully, and respecting case-insensitive matching.
