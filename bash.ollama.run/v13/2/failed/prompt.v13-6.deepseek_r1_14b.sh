#Thinking...
#Okay, so I'm trying to fix a bash completion script for the `ollama` command. The main issue seems to be with how the script activates. Right now, it's activating in situations where it shouldn't, like when the command is just `ollama` or something else.
#
#First, let me understand the problem. The current activation condition checks if the second word is "run". But according to the requirements, this check is wrong because `COMP_WORDS[1]` isn't the command name but the first argument after the command. So when someone types `ollama run`, the script should activate only then.
#
#Looking at the original script, I see that the activation condition might be incorrect. It probably uses something like checking if `COMP_WORDS[2]` is "run", which would be wrong because indexes are off.
#
#I remember in bash, `$COMP_WORDS` is zero-indexed. So for a command like `ollama run`, `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". Therefore, the condition should check if both `[0]` is "ollama" AND `[1]` is "run".
#
#Wait, no, in the user's problem, they mentioned that the current script might be using something like checking `[[ "${COMP_WORDS[2]}" != "run" ]]`, which would never be true because when you're completing after typing `llama:`, the third word is being completed. So the condition should prevent activation unless the command is exactly `ollama run`.
#
#The user says that the root cause is incorrect array indexing in the condition. The fix they want is to change the condition to check if either `[0]` isn't "ollama" OR `[1]` isn't "run". That way, only when both are true does the script activate.
#
#So I need to modify the condition line to use `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`. This will make sure that the completion only triggers for `ollama run`.
#
#I should also ensure that all other parts of the script remain unchanged, especially the handling of colons in model names and processing the output of `ollama list` correctly. That means I shouldn't touch the parts where it processes the models or handles the colon completions.
#
#Putting it all together, I'll replace the existing activation condition with the corrected one.
#...done thinking.
#
#The script now checks if both `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run", ensuring completion only for `ollama run`.

# Completion script for ollama command.

_ollama_run_completions() {
    local cur prev words
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[${COMP_CWORD}-1]}"
    words=("${COMP_WORDS[@]}")

    # Only activate when the command is 'ollama run'
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Handle colons in model names correctly
    _get_comp_words_by_ref -n : cur

    # Extract models from ollama list output
    while IFS=$'\t' read -r name id size modified; do
        COMPREPLY+=("$name")
    done < <(ollama list | grep -v '^NAME' | grep -v '^$')

    # Remove leading colon if present in completions
    __ltrim_colon_completions "$cur"

    return 0
}

# Bind the completion function to 'run' subcommand of 'ollama'
complete -F _ollama_run_completions ollama
