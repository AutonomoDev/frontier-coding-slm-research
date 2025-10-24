#Thinking...
#Alright, I need to write a bash completion function for the command 'ollama run <model>'. Let me break down the requirements step by step.
#
#First, the function should only trigger when the user is completing after typing 'ollama run'. So, I need to check if the previous word is 'run' and that the command starts with 'ollama'.
#
#Next, I have to retrieve the list of models by running 'ollama list' once. I can't pipe it directly into a loop because that creates a subshell. Instead, I'll capture the output into a variable. So, I'll use OLlama_list=$(ollama list) to store the output.
#
#Then, I need to filter the models based on the current word being completed. I'll get the current word using COMP_WORDS and COMP_CWORD. For each model in the list, I'll check if it starts with the current prefix.
#
#After filtering, if there are multiple matches, I should sort them alphabetically. Using sort -u will handle that, ensuring unique entries if any duplicates exist.
#
#I have to populate COMPREPLY correctly. Instead of building it manually, I can use compgen with the filtered list and the current word as a prefix.
#
#I also need to ensure graceful failure. If 'ollama list' fails or returns nothing, the function should do nothing without errors. So, I'll check if OLlama_list is empty before proceeding.
#
#Another important point is not relying on external dependencies. Using built-ins like _get_comp_words_by_ref is okay, but I need a fallback in case it's missing. So, I'll set cur and prev manually using COMP_WORDS and COMP_CWORD.
#
#Finally, I have to wire the function to 'ollama' so that typing 'ollama run <Tab>' triggers it. This means defining the function and ensuring it's attached correctly with complete -F.
#
#For installation, the user should source the script or add a line to their .bashrc to load the completion function. Testing immediately after sourcing will confirm if it works.
#...done thinking.

# ollama_run_completion: Bash completion for `ollama run <model>`
# Triggers when completing after `run` in `ollama run`

ollama_run_completion() {
    # Get current word and previous word
    _get_comp_words_by_ref -n 2 -c cur -p prev || {
        cur=${COMP_WORDS[-1]}
        prev=${COMP_WORDS[${COMP_CWORD}-1]}
    }

    # Check if we're completing the model argument after `run`
    if [[ "$prev" != "run" || "$COMMAND" != "ollama" ]]; then
        return
    }

    # Get list of models, exit if none found or command fails
    OLlama_models=$(ollama list 2>/dev/null)
    if [[ -z $OLLama_models ]]; then
        return
    }

    # Filter models starting with current word and sort
    COMPREPLY=($(compgen -W "$OLLama_models" -- "$cur" | sort))
}

# Install: Add to .bashrc (or similar shell config)
# source /path/to/ollama_run_completion.sh
# For immediate use: source the script after adding it

complete -F ollama_run_completion ollama

