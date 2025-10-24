#Thinking...
#Alright, I need to create a robust Bash completion script for the `ollama run` command. The core requirement is to provide autocompletion suggestions for model names when the user types `ollama run ` and presses the Tab key. Let me break down how I can approach this.
#
#First, the script must activate only when the token immediately following `run` is being completed. So, I'll search through `COMP_WORDS` to find where `run` is located. If the current word index (`COMP_CWORD`) is exactly one more than the index of `run`, then we trigger the completion.
#
#Next, I need to fetch the list of available models using `ollama list`. The output includes headers and model names with colons, like `llama3:latest`. Parsing this correctly is crucial. Using `awk` to skip the header line and extract the first column seems reliable since it handles variable whitespace better than `cut`.
#
#Handling colons in model names requires adjusting `COMP_WORDBREAKS`. By default, `:` is a word break character, which can interfere with completion. I'll save the original `COMP_WORDBREAKS`, remove the colon temporarily, and then restore it after processing to avoid side effects.
#
#For filtering suggestions based on what the user has typed so far, using `compgen -W` is safe because it uses plain string matching without regex, preventing any unexpected behavior. This ensures that only model names starting with the current word are suggested.
#
#I must ensure uniqueness in the suggestions. Using an associative array to track seen words helps deduplicate the list efficiently.
#
#The script should not fall back to filename completion if no models match. So, I'll avoid using options like `-o default` and handle cases where `compgen` returns nothing gracefully by leaving `COMPREPLY` empty.
#
#Registering the completion function with `complete -F _ollama_run_completion ollama` ensures that it's only triggered for the `ollama` command. Also, including a fallback in `_get_comp_words_by_ref` handles cases where the helper isn't available, manually setting `cur` and `prev` from `COMP_WORDS`.
#
#Testing edge cases is important. For example, when the user types `codellama:`, pressing Tab should still suggest both versions since the colon doesn't affect the prefix matching.
#
#Finally, I'll structure the script with comments for clarity, ensuring each step is well-documented. The script must be self-contained and sourced correctly to enable the completion functionality without errors.
#...done thinking.
#
#```bash
## Bash completion script for ollama run command
## This script provides model name autocompletion for `ollama run` command.
#
# Olivella: Okay, so I need to create a bash completion script for the 'ollama run' command. The main goal is to provide suggestions for model names when the user types 'ollama run ' and presses Tab. Let's break down what needs to be done step by step.
#
#First, I should understand how bash completions work. Bash uses functions that are triggered when a specific command is being typed. These functions use variables like COMP_WORDS (the array of words in the current command line) and COMP_CWORD (the index of the current word). The function will generate possible completions and store them in COMPREPLY.
#
#For this script, I need to ensure that completion only activates when 'run' is the subcommand. So I'll search through COMP_WORDS to find where 'run' occurs and check if the current word is right after it.
#
#Next, I need to get the list of available models from 'ollama list'. The output includes headers and model names. Parsing this output correctly is crucial. Using awk makes sense here because it's robust against variable whitespace. I'll skip the header line and extract the first column which contains the model names.
#
#Handling colons in model names is important. Since ':' is a word break character, bash won't handle them properly by default. I'll need to temporarily remove ':' from COMP_WORDBREAKS to allow completion to work correctly with these models. But I must remember to restore it after processing to avoid affecting other commands.
#
#Filtering the suggestions based on what the user has already typed is necessary for a good experience. Using compgen -W allows me to safely match against the current word without worrying about regex issues.
#
#I also need to ensure that the suggestions are unique. This can be done by using an associative array where each suggestion is added only once.
#
#Another consideration is not falling back to filename completion if no models match. This means I shouldn't use options like -o default or -o bashdefault when registering the completion function.
#
#Finally, I should handle cases where 'ollama list' might fail or return nothing gracefully. The script should exit quietly without causing any errors or suggesting filenames.
#
#Putting it all together, I'll write a function that does these steps:
#
#1. Check if the current command is for ollama and if 'run' is the subcommand.
#2. Fetch the list of models using 'ollama list'.
#3. Parse the output to extract model names.
#4. Temporarily adjust COMP_WORDBREAKS to handle colons.
#5. Generate completions based on the current word being typed.
#6. Ensure unique suggestions.
#7. Handle any potential failures gracefully.
#
#I'll also make sure to include comments in the script for clarity and structure it in a way that's easy to understand and maintain.
#</think>

# Bash completion script for ollama run command

_ollama_run_completion() {
    local cur prev run_index model_list old_wb

    # Find the index of 'run' in COMP_WORDS
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion for the word immediately after 'run'
    if [[ -z $run_index ]] || (( COMP_CWORD != run_index + 1 )); then
        return 0
    fi

    # Fetch list of models from ollama list, skipping header
    model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models found or command failed, exit quietly
    if [[ -z "$model_list" ]]; then
        return 0
    fi

    # Handle colons in model names by adjusting word breaks
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate unique suggestions using compgen and dedupe with awk
    COMPREPLY=($(compgen -W "$model_list" -- "$cur" | awk '!seen[$0]++'))

    # Restore original word breaks
    COMP_WORDBREAKS=$old_wb

    return 0
}

# Register the completion function without fallback to filenames or default options
complete -F _ollama_run_completion ollama
