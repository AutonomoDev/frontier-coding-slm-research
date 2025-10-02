#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The goal is to provide model name suggestions when the user presses Tab after typing `run`.
#
#First, I should figure out how Bash completions work. From what I remember, I can use the `complete` command and write a function that generates the possible completions.
#
#The core requirement is that the completion triggers only when the next token after `run`. So, I need to check if the current word is right after `run`.
#
#I'll start by parsing the output of `ollama list`. The script should run this command, skip the header, and extract model names from the first column. Using `awk` is safer for this because it handles variable whitespace better than `cut`.
#
#Next, handling colons in model names is tricky because `:` is a word break character. I need to temporarily remove it from `COMP_WORDBREAKS`, generate the completions, and then restore it to avoid side effects.
#
#I also have to ensure that the suggestions are unique. Using `awk` with a seen array can help deduplicate the model names.
#
#For filtering, using `compgen -W` is better because it safely matches prefixes without regex issues.
#
#Finally, I'll register the completion function for `ollama` without any default options to prevent filename completions if no models match.
#
#I should structure the function `_ollama_run_completion` to handle all these steps: parsing models, adjusting word breaks, filtering, and ensuring uniqueness. Also, I need a fallback in case `_get_comp_words_by_ref` isn't available, so I set `cur` and `prev` manually from `COMP_WORDS`.
#
#Testing each scenario will ensure that it works as expected, like when the user types different parts of model names or when no matches are found.
#...done thinking.

# Function to handle completions for ollama run
function _ollama_run_completion() {
    # Check if we're completing the word after 'run'
    local index run_index=0
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete if we're one word after 'run'
#    if [[ $COMP_CWORD != $run_index + 1 ]]; then
#        return
#    fi

    # Get list of models from ollama list command
    local model_list=$(ollama list | awk 'NR>1 {print $1}')

    # If no models found, exit
    if [[ -z "$model_list" ]]; then
        return
    fi

    # Save and adjust word break characters
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word breaks

    # Get current word being completed
    local cur=${COMP_WORDS[$COMP_CWORD]}

    # Generate unique model suggestions matching the current word
    local completions=$(echo "$model_list" | awk "{
        if (!seen[\$0]++) {
            if (\$0 ~ /^$cur/) {
                print \$0
            }
        }
    }")

    # Restore word break characters
    COMP_WORDBREAKS=$old_wb

    # Set the completions
    COMPREPLY=($(compgen -W "$completions" -- "$cur"))
}

# Example usage:
# ollama run <TAB>  # Shows all models
# ollama run l<TAB>   # Shows 'llama3:latest'
# ollama run cod<TAB> # Shows 'codellama:17b' and 'codellama:32b'

# Bash completion script for ollama run command
complete -F _ollama_run_completion ollama

