# [[HUMAN COMMENTED-OUT]]
# Thinking...
# Alright, let's tackle this problem. I need to create a Bash function that enables tab completion for the command `ollama run <model>`. The user has provided specific steps and constraints, so I'll follow them closely.
# 
# First, I know that the function should be named `_ollama_completions()`. Inside this function, there are several steps I must perform in order.
# 
# The first step is to validate the command. I need to check if the first two words of the command are `ollama` and `run`, respectively. If not, the function should return without providing any completions. So I'll use an if statement with `[[ ]]` and a logical AND to check both conditions. If either is false, I set `COMPREPLY` to empty and return.
# 
# Next, I need to extract the current word (`cur`) and the previous word (`prev`). The user specified using `_get_comp_words_by_ref -n : cur prev`. This command helps get the words by reference, especially handling cases where there might be colons or other special characters. It's important to use this correctly to avoid issues with paths or model names that have colons.
# 
# Then, I must fetch the list of available models. The user provided a specific way to do this: run `ollama list`, ignore any errors by redirecting stderr, skip the first line (hence `tail -n +2`), and extract the first column using `awk '{print $1}'`. This gives me all the model names as a string. I'll store this in the variable `models`.
# 
# I should also handle cases where `ollama` isn't installed or doesn't return any models. So, before fetching models, I check if `command -v ollama` exists. If not, set `COMPREPLY` to empty and return. Similarly, after fetching models, if the result is empty, do the same.
# 
# Once I have the models, I need to generate completions using `compgen`. The user specified using `-W "$models" -- "$cur"` which means that compgen will complete against the list of models, considering the current word. This should correctly provide model names as possible completions when the user tabs after typing `ollama run`.
# 
# After generating `COMPREPLY`, I need to sort it and trim any colons from the results. The user wants the output sorted, so I'll use `printf` to print each element on a new line, then pipe that into `sort`. Also, calling `__ltrim_colon_completions "$cur"` is necessary to handle cases where models might have colons, ensuring they are trimmed correctly.
# 
# Finally, I need to make sure the function completes properly. The `complete` command with `-F _ollama_completions ollama` tells Bash to use this function for completing the `ollama` command.
# 
# I should also ensure that all the steps follow the constraints: no arrays for models, no using `COMP_CWORD`, and so on. Each step is crucial to prevent errors and handle edge cases like missing commands or empty model lists.
# 
# Putting it all together, I'll structure the function with these steps in order, adding inline comments where necessary for clarity.
# ...done thinking.

# Bash Completion Generator — ollama run <model>

function _ollama_completions() {
    # Validate command is exactly "ollama" followed by "run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=();
        return;
    };

    # Extract current and previous word for completion
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=();
        return;
    fi

    # Fetch available models from ollama list output
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # Handle empty model list
    if [[ -z "$models" ]]; then
        COMPREPLY=();
        return;
    fi

    # Generate completions for the current word against available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions and trim colons from results
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register completion function for ollama command
complete -F _ollama_completions ollama
