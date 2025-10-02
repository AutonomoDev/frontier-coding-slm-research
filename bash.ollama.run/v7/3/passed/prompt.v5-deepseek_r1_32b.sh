#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run ` and presses TAB. Let me think through how to approach this.
#
#First, I know that bash-completion scripts use functions called by the complete command. So I'll need a function that handles the completion logic.
#
#The core requirement is that the completion should only trigger for the token immediately after `run`. That means I have to find where `run` appears in COMP_WORDS and check if the current word is the next one.
#
#Next, getting the model names from `ollama list`. The output has a header line followed by entries. I need to skip the first line and extract the first column. Using awk seems robust because it handles variable whitespace better than cut.
#
#Handling colons in model names is tricky. Since colon is in COMP_WORDBREAKS, it breaks word completion. So I'll temporarily remove the colon from WORDBREAKS before generating matches and restore it afterward to avoid side effects.
#
#For filtering suggestions based on what's already typed, using compgen with -W option is safer because it doesn't treat the input as a regex, preventing potential issues with special characters.
#
#Ensuring unique suggestions is important. Using an associative array or awk to deduplicate will help prevent duplicates in the output.
#
#I also need to make sure that if `ollama list` fails or returns nothing, the script handles it gracefully without errors and doesn't fall back to filename completion. So I'll check the exit status of the ollama command and only proceed if it's successful.
#
#Registering the function correctly is another step. Using `complete -F _function_name ollama` without any default options ensures that only our function handles completions for ollama, avoiding fallbacks to other completion mechanisms.
#
#Putting it all together:
#
#1. The function checks each word in COMP_WORDS to find 'run' and verifies if the current position is right after it.
#2. It runs `ollama list`, parses with awk to get model names, ensuring we skip errors.
#3. Temporarily modifies COMP_WORDBREAKS to handle colons, uses compgen for filtering, and ensures uniqueness.
#4. Handles edge cases like no models found or ollama command failure.
#
#I need to structure the function carefully, saving old WORDBREAKS, modifying them, generating the word list, filtering, deduping, then restoring WORDBREAKS before returning. Also, ensuring that all code paths restore correctly, even if errors occur.
#
#Finally, testing each scenario: empty completion, partial matches with colon, and cases where no models match to ensure it behaves as expected without suggesting files or showing errors.
#...done thinking.

# Bash completion script for `ollama run` command
# Provides model name autocompletion after `ollama run`

_ollama_run_completion() {
    # Find the index of 'run' in COMP_WORDS
    local run_index=-1
    local i=0
    
    while [[ $i -lt ${#COMP_WORDS[@]} ]]; do
        if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
            run_index=$i
            break
        fi
        ((i++))
    done

    # Only trigger completion for the word immediately after 'run'
    if [[ $run_index -eq -1 ]] || [[ ${COMP_CWORD} -ne $(($run_index + 1)) ]]; then
        return
    fi

    # Get list of models from `ollama list` output
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    
    # If no models found or command failed, exit early
    if [[ $? -ne 0 ]] || [[ -z "$models" ]]; then
        return
    fi

    # Remove colon from word break characters temporarily
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Extract current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate unique suggestions using compgen and filter by current input
    local suggestions=$(echo "$models" | awk '!seen[$0]++' | compgen -W "$(cat)" -- "$cur")

    # Restore original word break characters
    COMP_WORDBREAKS=$old_wb

    # Set completions, avoiding duplicates in COMPREPLY
    if [[ -n "$suggestions" ]]; then
        COMPREPLY=($(echo "$suggestions"))
    fi

    # Do not fall back to filename completion
    compopt +o default +o bashdefault 2>/dev/null
}

# Register the completion function for `ollama`
complete -F _ollama_run_completion ollama
