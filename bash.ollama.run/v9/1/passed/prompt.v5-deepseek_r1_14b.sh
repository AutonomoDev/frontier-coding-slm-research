#Thinking...
#Okay, so I need to create a bash completion script for the `ollama run` command. The goal is to dynamically complete model names from the output of `ollama list`, and handle model names that have colons without breaking the completion.
#
#First, I remember that by default, Bash splits words on colons, which causes issues because model names like `codellama:13b` get split into two parts. This messes up the context for completing after `run`.
#
#I need to write a function `_ollama_completions` that handles this. The function should be triggered when the user types `ollama run` and starts typing a model name.
#
#So, the steps I think are:
#
#1. **Save the original word break settings**: Because we're going to modify them temporarily.
#2. **Modify COMP_WORDBREAKS** to remove the colon so it doesn't split on it anymore.
#3. **Reparse the command line** using `_get_comp_words_by_ref` with the new settings to get correct `cur` and `prev`.
#4. **Restore the original word breaks** after we're done to avoid affecting other parts of the script.
#
#Then, check if the previous word is `run`. If so, fetch the list of models from `ollama list`, extract the model names, and use `compgen` to filter them based on the current input.
#
#I should also make sure that the function correctly uses `COMPREPLY` to set the possible completions. Plus, register this function with `complete` so it knows to use `_ollama_completions` for `ollama`.
#
#Testing this would involve typing `ollama run co`, expecting it to suggest models starting with 'co', like `codellama:13b`. Without the word break fix, typing `codellama:` would cause issues because Bash splits on the colon.
#
#I think using `awk` to extract model names after the first line of `ollama list` is a good approach. Also, ensuring that the function doesn't interfere with other parts of the script by restoring the original word breaks immediately after parsing.
#
#Overall, the key is to handle the colons correctly and dynamically fetch the models each time the completion is triggered.
#...done thinking.

# 1. Simple Static Completion
complete -W "option1 option2 option3" example_cmd
# This line creates a basic completion for 'example_cmd' with predefined options.

# 2. Dynamic Completion with a Function
_example_cmd_completions() {
    local cur prev
    # `cur` is the current word being typed, `prev` is the previous word
    compgen -W "option1 option2 option3" -- "$cur"
}
complete -F _example_cmd_completions example_cmd

# 3. Context-Aware Completion
_app_completions() {
    local cur prev
    # If last argument was 'app', suggest subcommands
    if [[ "$prev" == "app" ]]; then
        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
    elif [[ "$prev" == "run" ]]; then
        # If last argument was 'run', suggest models
        COMPREPLY=( $(compgen -W "model:small model:large" -- "$cur") )
    fi
}
complete -F _app_completions app

# 4. Advanced Completion for Non-Standard Word Breaks
_ollama_completions() {
    local cur prev
    local _old_wb=${COMP_WORDBREAKS}
    
    # Remove colon from word break characters to prevent splitting on it
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=$_old_wb

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# 5. Installation Instructions as Code Comments
# Add the following to your ~/.bashrc to enable completion from '.bash_completion.d/':
# [[ ":$(cat /etc/*release | awk '{print $1}'):" == ":*nix:*" ]] && {
#     for c in ~/.bash_completion.d/*; do
#         [[ -f "$c" ]] && source "$c"
#     done
# }

