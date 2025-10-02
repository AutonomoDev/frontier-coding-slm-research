#Thinking...
#Alright, I need to create a robust Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when a user presses <TAB> after typing `ollama run`.
#
#First, I'll start by understanding the requirements. The script must be self-contained and sourced via `source my_script.sh`. It should only activate when the user types `run` followed by something and then hits <TAB>.
#
#I know that Bash completion uses functions to handle these scenarios. So I'll need to write a function `_ollama_run_completion` that gets called when the user is trying to complete after `run`.
#
#The core logic involves parsing the output of `ollama list`. The output has headers, so I need to skip the first line and extract model names from the first column. Using `awk 'NR>1 {print $1}'` seems reliable because it handles variable whitespace.
#
#Next, handling colons in model names is tricky. By default, `:` is considered a word break character, which would split model names like `codellama:32b`. To prevent this, I need to temporarily remove the colon from `COMP_WORDBREAKS` before generating completions and then restore it afterward.
#
#I also need to ensure that completion only happens when the current word is the one immediately after `run`. So I'll search `COMP_WORDS` for the index of "run" and check if the current word index (`COMP_CWORD`) is right after it.
#
#For filtering suggestions based on what the user has typed, using `compgen -W "$wordlist" -- "$cur"` is safe and efficient. This avoids regex issues and ensures only prefix matches are considered.
#
#Deduplication is important to avoid duplicate suggestions. Using `awk '!seen[$0]++'` will help in ensuring each model name appears once.
#
#I must register the function using `complete -F _ollama_run_completion ollama` without any default fallbacks, so no filename completions should occur if there are no models matching.
#
#Now, putting it all together. The script starts by checking if Bash version is 3 or higher to support completion features. Then, it defines the function which does the following:
#
#1. Saves the original `COMP_WORDBREAKS` and removes the colon.
#2. Parses model names using `ollama list` and `awk`.
#3. Finds the position of "run" in `COMP_WORDS` to determine if we're completing the right token.
#4. Uses `compgen` to filter and generate suggestions based on the current word.
#5. Restores `COMP_WORDBREAKS` before returning.
#
#Testing edge cases like when there are no models or invalid commands is crucial. The script should handle these gracefully by providing no suggestions without errors.
#
#Finally, I make sure all code paths restore `COMP_WORDBREAKS` to prevent any side effects in subsequent completions.
#...done thinking.

# Bash completion script for ollama run command

# Function to complete model names after "run" subcommand
_ollama_run_completion() {
    # Save original word break settings
    local old_wb=$COMP_WORDBREAKS
    # Temporarily remove colon from word breaks to handle model names with colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get the index of "run" in command words array
    local run_index=$(printf '%s\n' "${COMP_WORDS[@]}" | grep -n '^run$' | cut -d':' -f1)
    
    # Only complete if current word is directly after "run"
    if [ "$COMP_CWORD" != "$run_index + 1" ]; then
        return
    fi

    # Get available models by parsing ollama list output
    local model_list=$(ollama list | awk 'NR>1 {print $1}')

    # If no models found, exit early
    if [ -z "$model_list" ]; then
        return
    fi

    # Generate completions based on current word
    local cur=${COMP_WORDS[COMP_CWORD]}
    
    # Use compgen to generate word-based matches for the current cursor position
    COMPREPLY=( $(compgen -W "$model_list" -- "$cur") )

    # Restore original word break settings before returning
    COMP_WORDBREAKS=$old_wb
}

# Register completion function for ollama command, specifically for "run" subcommand
complete -F _ollama_run_completion ollama
