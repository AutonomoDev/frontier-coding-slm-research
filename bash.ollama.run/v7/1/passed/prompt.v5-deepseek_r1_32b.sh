#Thinking...
#Okay, I need to create a robust Bash completion script for the `ollama run` command. Let me go through the requirements step by step.
#
#First, the script should only activate when the user is typing the token right after `run`. So, I'll search `COMP_WORDS` for the index of `run` and check if the current word is the next one.
#
#Next, I need to get the list of models from `ollama list`. The output has a header line, so I'll skip that. Using `awk` to extract the first column seems safe because it handles variable whitespace better than `cut`.
#
#Handling colons in model names is crucial. Since colon is in `COMP_WORDBREAKS`, I'll temporarily remove it before generating matches and restore it afterward. This ensures that completions work correctly without breaking other completion behaviors.
#
#Filtering the suggestions based on what the user has typed is important. Using `compgen -W` with the current word will handle prefix matching safely, avoiding any regex issues.
#
#I must ensure no filename fallbacks. That means not using options like `-o default` when registering the completion and making sure that if there are no matches, nothing else happens.
#
#Unique suggestions are a must, so I'll use `awk '!seen[$0]++'` to deduplicate the list of models.
#
#The script should be compatible with standard Bash and `bash-completion` v2. I'll rely on `COMP_WORDS`, `COMP_CWORD`, and `COMPREPLY` for this.
#
#Registering the function correctly without any fallback options is another key point. The completion function will be registered using `complete -F`.
#
#I also need to handle cases where `ollama list` might fail or return nothing. The script should exit quietly in such cases, providing no suggestions but also no errors.
#
#Avoiding common mistakes like forgetting to restore `COMP_WORDBREAKS` is something I must be careful about. I'll structure the function so that it always restores the original value, even if there's an early exit.
#
#Putting it all together, the script will:
#
#1. Check if the current command position is right after `run`.
#2. Fetch the list of models using `ollama list` and parse it with `awk`.
#3. Temporarily adjust `COMP_WORDBREAKS` to handle colons.
#4. Use `compgen` to filter suggestions based on the current input.
#5. Ensure all edge cases, like partial model names or no matches, are handled gracefully.
#
#Testing each part step by step will help catch any issues early. For example, verifying that models with colons complete correctly and that the script doesn't suggest anything when there's no match.
#
#Finally, I'll make sure the script is self-contained and can be sourced to enable the completion without any additional setup.
#...done thinking.

# Bash completion script for `ollama run` command
# This script provides model name autocompletion for `ollama run`.

_ollama_run_completion() {
    local cur prev cmd run_index

    # Get current word being typed and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Find the index of 'run' in COMP_WORDS
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion if current word is immediately after 'run'
    if [[ "$run_index" -eq $(($COMP_CWORD - 1)) ]]; then
        # Get list of models from `ollama list` output, skipping header
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

        # Handle empty or invalid output gracefully
        if [[ -z "$models" ]]; then
            return
        fi

        # Temporarily remove colon from word break characters to handle model names with colons
        local old_wb=$COMP_WORDBREAKS
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Generate completion suggestions using compgen for safe prefix matching
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Restore original word break characters
        COMP_WORDBREAKS=$old_wb

        # Ensure unique suggestions and sort them
        local seen
        declare -A seen
        local completions=()
        for suggestion in "${COMPREPLY[@]}"; do
            if [[ -z ${seen[$suggestion]} ]]; then
                seen[$suggestion]=1
                completions+=("$suggestion")
            fi
        done
        COMPREPLY=("${completions[@]}")

        # Sort completions to ensure consistent order
        IFS=$'\n' COMPREPLY=($(sort <<< "${COMPREPLY[*]}"))
        unset IFS

    fi
}

# Register the completion function with bash-completion
complete -F _ollama_run_completion ollama
