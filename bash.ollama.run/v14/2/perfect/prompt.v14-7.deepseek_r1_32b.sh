#Thinking...
#Okay, so I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this step by step.
#
#First, I remember that Bash completions involve writing a function that's triggered when you press Tab after typing a command. The function needs to generate possible completions based on what's been typed so far.
#
#The task specifies that the completion should only activate for `ollama run`. So, I need to check that the first two words in the command are "ollama" and "run". That means checking `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, we return early without setting any completions.
#
#Next, handling model names with colons. I recall that by default, Bash splits words on colons, which can cause issues when completing model names like `codellama:13b`. To fix this, I should use `_get_comp_words_by_ref -n : cur prev` to prevent splitting and handle the current (`cur`) and previous (`prev`) words correctly.
#
#Parsing the output of `ollama list` is crucial. The output includes headers and extra columns, so I need to skip the first line. Using `awk '{print $1}'` will extract just the model names from each line. But before that, I should check if the `ollama` command exists using `command -v ollama`, otherwise, there's nothing to complete.
#
#Once I have the list of models, I need to filter them based on the current word being completed (`cur`). Using `compgen -W "$models" -- "$cur"` will generate the possible completions. After generating `COMPREPLY`, I must call `__ltrim_colon_completions "$cur"` to ensure that any colon in the model names doesn't mess up the display.
#
#Putting it all together, I'll write a function `_ollama_completions` that does these steps:
#
#1. Check if the command is `ollama run`. If not, return.
#2. Use `_get_comp_words_by_ref` to handle colons properly.
#3. Check if `ollama` exists; if not, set an error message and return.
#4. Run `ollama list`, parse it to get model names, skipping the header.
#5. Generate completions using `compgen`.
#6. Apply `__ltrim_colon_completions` to fix any colon issues.
#
#I also need to make sure that all edge cases are handled, like when there are no models installed or if the `ollama` command isn't found. The script should be robust and not cause errors in these scenarios.
#
#Finally, I'll register the completion function with `complete -F _ollama_completions ollama`, so that Bash uses this function for completions after typing `ollama`.
#...done thinking.

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colon in model names
    _get_comp_words_by_ref -n : cur prev 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Check if ollama command exists
    command -v ollama &>/dev/null || {
        COMPREPLY=()
        return
    }

    # Get list of models
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate completions
    if [[ "$models" ]]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    else
        COMPREPLY=()
    fi

    # Fix colon handling in completion display
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
