#Thinking...
#Okay, I need to create a bash completion function for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list`, without using any external tools like jq. 
#
#First, I should understand how bash completions work. Typically, you write a function that populates the COMPREPLY array based on the current command and word being typed. So, I'll start by defining a function called `complete_ollama_run`.
#
#Next, I need to check if the current word being completed is exactly 'run', because the models come after that. So, in the function, I'll look at COMP_CWORD to see if it's 2 (since the command is ollama [0], run [1], and then model [2]).
#
#Then, I need to get the list of models by running `ollama list`. But wait, how does `ollama list` output? The user says it prints model names one per line or separated by whitespace. So, when we run ollama list, each model is on a new line. 
#
#I'll capture this output into a variable. If the command fails (like if ollama isn't installed), I should handle that gracefully by returning nothing. So, using `output=$(ollama list 2>/dev/null)` will capture it and suppress errors.
#
#Now, I need to split the output into individual models. Since each model is on its own line, I can use `tr '\n' ' '` to replace newlines with spaces, then split on whitespace using `read -a models`. This way, even if some lines are empty (maybe due to formatting issues), it should still work.
#
#Once I have the models array, I need to find all models that start with the current word. The current prefix is stored in `COMP_WORDS[COMP_CWORD]`, which might be part of a model name. So, for each model in the array, check if it starts with this prefix.
#
#I'll loop through each model and check using `startswith="${models[i]:0:${#cur}}"` where `cur` is the current word length. If the substring matches `cur`, add it to COMPREPLY as a possible completion.
#
#Also, I should make sure that the function is only triggered when the command starts with 'ollama run', so in the `_complete` function, check if `COMP_WORDS[0]` is 'ollama' and `COMP_WORDS[1]` is 'run'. 
#
#For installation, I need to source this script from the shell. So, the user can add a line like `source /path/to/script.sh` or add it to their .bashrc file. After that, they might need to enable bash completion with `complete -o default ...` commands.
#
#Putting it all together, the function will run ollama list, parse the models, and suggest completions based on the current prefix. If any step fails, like if ollama isn't found, it just returns without setting COMPREPLY.
#...done thinking.

# bash completion for `ollama run <model>`
complete_ollama_run() {
    # Only complete when command is 'ollama run'
    if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Get current word (could be empty or part of a model name)
    local cur=${COMP_WORDS[COMP_CWORD]}
    local models=()

    # Get list of available models, ignoring errors if ollama isn't installed
    output=$(ollama list 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        # Split output into individual models (handles both newline and whitespace separated outputs)
        tr '\n' ' ' <<< "$output" | read -a models
    fi

    # Filter models matching the current prefix and build completion list
    for model in "${models[@]}"; do
        if [[ ${model} == ${cur}* ]]; then
            COMPREPLY=(${COMPREPLY[@]} "$model")
        fi
    done
}

# Install: Add to your shell configuration (e.g., ~/.bashrc)
# source /path/to/this/script.sh
# Then run:
complete -o default -F complete_ollama_run ollama
