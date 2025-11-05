# Thinking...
# Okay, I need to generate a Bash completion function for the 'ollama' command based on the user's specifications. Let me break down what needs to be done step by step.
# 
# First, the function should start with _ollama_completions(). The first thing inside this function is to validate if the command being completed is indeed 'ollama'. So I'll check COMP_WORDS[0] and [1]. If they don't match 'ollama' and the specific subcommand, respectively, then I return early.
# 
# Next, I need to extract the current and previous words. Using _get_comp_words_by_ref with -n : will help here. This gets the current word (cur) and the previous one (prev), handling colons correctly.
# 
# Then, I have to fetch the list of models. I'll check if 'ollama' is installed using command -v. If not, return early. Then, run 'ollama list', take everything from the second line onwards, and extract the first column which should be the model names. If there are no models, again return early.
# 
# After that, generate completions using compgen with the models. The completions should match the current word (cur). Once generated, I sort them to ensure a consistent order. Finally, I call __ltrim_colon_completions to handle any colons in the completion strings.
# 
# I also need to make sure not to use arrays for models and avoid sorting input models as per the instructions. The code should be concise with inline comments explaining each key step.
# 
# Putting it all together, I'll structure each part of the function following the exact steps provided, ensuring all checks are in place and that colons are handled properly.
# ...done thinking.

_ollama_completions() {
    # Check if command is 'ollama' and specific subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Extract current and previous words
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch available models from ollama list
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # If no models found, exit early
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions based on current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions and handle colons
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register the completion function with bash
complete -F _ollama_completions ollama
