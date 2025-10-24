#Thinking...
#Okay, I need to write a bash-completion function for the command `ollama run <model>`. The user has given several specific requirements that I must follow carefully.
#
#First, the completion should only trigger when the user is completing the model argument after typing `ollama run`. So, I'll check if the previous word is 'run' and the command is 'ollama'. I also need to handle cases where there might be extra whitespace or other benign variations, so I shouldn't assume exactly two words in COMP_WORDS.
#
#Next, I need to retrieve the list of models by running `ollama list` once. The output should be stored in a variable without using pipes directly because that would create a subshell and lose array contents. Instead, I'll capture the output into a variable and then iterate over it safely.
#
#For prefix filtering, I have to use the current word being completed (from COMP_WORDS or COMP_CWORD) as the prefix. Models should only be included if their names start with this prefix. I shouldn't use any hacks but perform a straightforward match using `[[ $model == "$cur"* ]]`.
#
#Sorting is another requirement: if there are multiple matching models, they need to be sorted alphabetically before assigning them to COMPREPLY. This can be done using the `sort` command.
#
#I have to ensure that COMPREPLY is populated correctly. I can either build it manually or use `compgen -W ... -- "$cur"`. Using compgen might be more efficient and cleaner.
#
#Graceful failure is important too. If `ollama list` fails or returns empty, the function should return without providing any completions but also without errors.
#
#No external dependencies are allowed except Bash built-ins and GNU coreutils like sort. I need to make sure that the script doesn't rely on any non-standard tools.
#
#I also need to handle cases where `_get_comp_words_by_ref` is missing or fails by including a fallback that manually sets `cur` and `prev` from COMP_WORDS and COMP_CWORD.
#
#Finally, I must wire the function so that typing `ollama run <Tab>` triggers it. This means defining a completion function for 'ollama' that checks if the previous word is 'run'.
#
#Putting it all together, I'll structure the script as follows:
#
#1. Define the completion function `_complete_ollama_run_model`.
#2. Use `_get_comp_words_by_ref` to get `cur` and `prev`, with a fallback.
#3. Check if the command is `ollama` and the previous word is `run`.
#4. Run `ollama list`, capture output into a variable, and read each line into an array.
#5. Filter models by prefix using `grep -i` for case-insensitive matching.
#6. Sort the filtered models alphabetically.
#7. Use `compgen` to generate possible completions and assign to COMPREPLY.
#
#Testing this function is crucial to ensure it handles all edge cases, like empty output from `ollama list`, correct prefix filtering, and proper sorting. Also, ensuring that the completion doesn't interfere with other commands under `ollama` except when necessary.
#
#I should also provide installation instructions so users can easily source the script in their `.bashrc` or similar files, making sure to reload the configuration for changes to take effect immediately.
#...done thinking.

# Bash completion function for ollama run <model>
_ollama_run_completion() {
    local cur prev
    # Fallback if _get_comp_words_by_ref is not available
    if ! _get_comp_words_by_ref cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only trigger completion for 'ollama run ...'
    if [[ "${COMP_WORDS[0]}" == "ollama" && "$prev" == "run" ]]; then
        local models
        # Run ollama list and capture output
        if ! models=$(ollama list 2>/dev/null); then
            return 0
        fi

        # Split into array, filter by prefix, sort alphabetically
        IFS=$'\n' read -d '' -r -a models <<< "$models"
        local matches=()
        for model in "${models[@]}"; do
            if [[ $model == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        # Sort and generate completions
        if [ ${#matches[@]} -gt 0 ]; then
            IFS=$'\n' sorted=$(printf "%s\n" "${matches[@]}" | sort)
            COMPREPLY=($(compgen -W "$sorted" -- "$cur"))
        fi
    fi
}

# Attach completion function to 'ollama'
complete -F _ollama_run_completion ollama

# Installation: Add the following line to your ~/.bashrc or similar and reload:
# source /path/to/this/script.bash

