#Thinking...
#Okay, so I need to help fix this Bash shell completion script for the `ollama` command. The user provided some specific requirements and a problem statement.
#
#First, let me understand what's going on here. The goal is to generate a completion script that works correctly when someone types `ollama run <TAB>`. So, the script should only activate in this exact scenario.
#
#Looking at the critical requirements:
#
#1. **Activation Condition:** The script should only trigger when the command is exactly `ollama run`. That means checking if `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". I need to make sure that the condition in the completion function reflects this correctly.
#
#2. **Handling Colons:** Model names can have colons, like `llama:7b`. So, when the script processes these, it shouldn't split on the colon. The user mentioned using `_get_comp_words_by_ref -n :` which tells Bash not to split words at colons. Also, after getting completions, I should call `__ltrim_colon_completions "$cur"` to handle cases where a colon is already present.
#
#3. **Processing `ollama list`:** The script needs to parse the output of `ollama list`, skipping the header line and empty lines, then extract model names from the first column. That means after running `ollama list`, I should read each line, skip if it's the header or empty, and then take everything before the first space as the model name.
#
#Now, looking at the common pitfalls to avoid:
#
#- **Incorrect Array Indexing:** The script must not check `COMP_WORDS[1]` as the command name because that would be incorrect. It should always refer to `COMP_WORDS[0]` for the command and `[1]` for the first argument.
#
#- **Forgetting `__ltrim_colon_completions`:** This function is crucial after handling completions to ensure that colons don't cause issues in the completion list.
#
#The user mentioned that the root cause was incorrect array indexing, so the main fix is changing the condition to correctly check `[0]` and `[1]`.
#
#In the original script (Gemma 27b), the condition might have been incorrectly checking `COMP_WORDS[1]` as "ollama" or something similar. The corrected line should be `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`, which ensures that we're only activating when the command is exactly `ollama run`.
#
#So, putting it all together, I'll structure the completion function as follows:
#
#- The function is named `_ollama_run` and is called from `complete -F`.
#- The first step is to check if the current command is not `ollama run`, and if so, return early.
#- Then, use `_get_comp_words_by_ref -n :` to get the current word being completed without splitting on colons.
#- Run `ollama list` and process each line, skipping headers and empties, extracting model names into a list.
#- Finally, call `__ltrim_colon_completions` before returning the completions.
#
#I need to make sure that only the condition line is changed, keeping everything else as per the original structure. That way, the colon handling and model parsing remain correct, and only the activation condition is fixed.
#...done thinking.

_ollama_run() {
    local cur prev words cword split
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    _get_comp_words_by_ref -n : cur prev words cword
    local models=$(ollama list | sed '/^NAME ID SIZE MODIFIED$/d;/^$/d' | awk '{print $1}')
    COMPREPLY=($(compgen -W "${models}" -- "$cur"))
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama_run ollama run
