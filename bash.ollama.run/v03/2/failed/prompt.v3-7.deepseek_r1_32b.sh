# Thinking...
# Okay, I need to write a bash-completion function for the command `ollama run <model>`. Let me go through each requirement step by step.
#
# First, triggering the completion. The function should activate only when the user is completing after typing `ollama run`. So, I'll check if the previous word is 'run' and the command is 'ollama'. Also, it should work even with extra whitespace or other benign variations. The simplest way is to ensure that the last word before the current position is 'run'.
#
# Next, retrieving the model list. I need to run `ollama list` exactly once. Since piping into a while read loop creates a subshell and loses array contents, I'll capture the output in a variable first. So, I'll store it in something like `models_output`.
#
# For prefix filtering, I have to use the current word being completed as the prefix. Only models that start with this prefix should be included. Using `[[ $model == "$cur"* ]]` seems straightforward and avoids hacks.
#
# Sorting is required if there are multiple matches. So after filtering, I'll sort them alphabetically before assigning to COMPREPLY.
#
# Populating COMPREPLY correctly: I can either build it manually or use compgen. Since the models need to be sorted, using `compgen -W` on a prepared list makes sense because it's efficient and handles the suggestions properly.
#
# Graceful failure is important. If `ollama list` fails or returns nothing, the function should return without errors. So I'll check if `models_output` is empty and handle that case by not setting COMPREPLY.
#
# No external dependencies mean using only Bash built-ins. For getting the current word (`cur`) and previous word (`prev`), I can use `_get_comp_words_by_ref`, but I need a fallback in case it's missing. So, if it fails, I'll manually set `cur` and `prev` from `COMP_WORDS`.
#
# Wiring the function to 'ollama' is done by adding the function under `complete -F _ollama_run_completion ollama`. This ensures that when completing after `ollama`, it uses this function.
#
# For installation instructions, the user needs to save the script somewhere and source it in their .bashrc. Providing a minimal example of where to save and how to activate is necessary so they can immediately use the completion.
#
# Putting it all together: The function will check if the command is `ollama` and the previous word is `run`. It'll fetch the model list, filter by the current prefix, sort them, and then populate COMPREPLY. If anything goes wrong, it gracefully exits without setting any completions.
#
# I think that covers all the requirements. Now, I can write the script with concise inline comments as per the user's request.
# ...done thinking.

# Bash completion function for ollama run <model>
_ollama_run_completion() {
    local cur prev words cword
    # Get current and previous words safely, fallback to manual extraction if _get_comp_words_by_ref is not available
    if ! _get_comp_words_by_ref -n : cur prev; then
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
        cur="${words[$cword]}"
        prev="${words[$cword-1]}"
    fi

    # Only trigger when previous word is 'run' and command is 'ollama'
    if [[ ${prev} == "run" && ${words[0]} == "ollama" ]]; then
        local models_output
        # Capture ollama list output without using subshells or pipes
        models_output=$(ollama list 2>/dev/null)

        # Check for valid output and split into array
        if [[ -n $models_output && $? -eq 0 ]]; then
            IFS=$'\n' read -r -d '' -a models <<< "$models_output"

            local matches=()
            for model in "${models[@]}"; do
                # Trim any extra whitespace and check prefix match
                model=$(echo "$model" | xargs)
                if [[ $model == "$cur"* ]]; then
                    matches+=("$model")
                fi
            done

            # Sort matches alphabetically
            IFS=$'\n' sorted_matches=($(sort <<< "${matches[*]}"))
            unset IFS

            # Prepare completions using compgen for proper handling of quotes and escaping
            COMPREPLY=($(compgen -W "${sorted_matches[*]}" -- "$cur"))
        fi
    fi
}

# Wire completion function to ollama command
complete -F _ollama_run_completion ollama

# Installation instructions:
# Add the above script to your .bashrc or a separate file like ~/.bash_completion.d/ollama
# Then add this line to your .bashrc:
# source ~/.bash_completion.d/ollama
# Reload shell configuration:
# source ~/.bashrc

