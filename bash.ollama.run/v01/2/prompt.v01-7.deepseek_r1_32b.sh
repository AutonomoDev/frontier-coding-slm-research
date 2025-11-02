Thinking...
Okay, I need to create a bash-completion function for the `ollama run` command. The goal is to dynamically list available models by parsing the output of `ollama list`. Let me break down how I can approach this.

First, I should understand how bash completions work. They typically involve functions that set the COMPREPLY array with possible completions based on the current input context. So, I'll need a function called `_ollama_run` that does this.

The command structure is `ollama run <model>`, so when the user types `ollama run` and presses Tab, we want to suggest available models. The completion should also filter these models based on what the user has already typed as the prefix.

I'll start by checking if the current command is `run`. Since bash passes the words in COMP_WORDS, I can check if the second word (index 1) is 'run'. If not, we don't provide completions here.

Next, I need to get the list of models. The user mentioned that `ollama list` outputs model names one per line or separated by whitespace. So, I'll run `ollama list`, read its output, and split it into an array. But I have to handle cases where the command might fail, like if `ollama` isn't installed.

To capture the output without relying on external tools, I can use command substitution. I'll wrap it in a subshell with `$()` and redirect stderr to /dev/null to silence errors. Then, I can split the output into an array using read -a, but since this is within a function, I should make it local to avoid side effects.

Once I have the models, I need to filter them based on the current word being completed. The current word is in COMP_WORDS[COMP_CWORD], and its prefix is ${current_word}. Using a loop, I'll check each model to see if it starts with this prefix and add matching ones to COMPREPLY.

Putting it all together, the function will:

1. Check if the command is 'run'.
2. Fetch models by running `ollama list`.
3. Split the output into an array.
4. Loop through each model and filter based on the current word.
5. Populate COMPREPLY with matches.

For installation, I'll instruct the user to add this function to their bash completion setup, either in `/etc/bash_completion.d/` or source it directly. They can test it by sourcing `~/.bashrc`.

I should also ensure that the script is robust, handles errors gracefully, and doesn't rely on any external binaries beyond what's standard in a POSIX environment.

Finally, I'll write the script with comments for clarity but keep it minimal as per the user's request.
...done thinking.

```bash
# Bash completion for `ollama run`
_ollama_run() {
    local models current_word prefix
    # Only trigger when "run" is the command
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi
    
    # Get model list from ollama, handle errors silently
    models=$(ollama list 2>/dev/null)
    
    # Split into array
    local IFS=$'\n'
    read -ra models <<< "$models"

    current_word="${COMP_WORDS[COMP_CWORD]}"
    prefix="$current_word"
    
    # Filter matching models and build completions
    for model in "${models[@]}"; do
        if [[ $model == $prefix* ]]; then
            COMPREPLY+=("$model")
        fi
    done
}

# Register the completion function
complete -F _ollama_run ollama
```

Installation:

1. Save this script to a file like `~/.bash_completion_ollama`.
2. Add the following line to your `~/.bashrc` or `/etc/bash.bashrc`:
   ```bash
   source ~/.bash_completion_ollama
   ```
3. Activate immediately by sourcing it in your current shell:
   ```bash
   . ~/.bash_completion_ollama
   ```

This script will provide completions for `ollama run` commands, filtering available models based on the typed prefix and gracefully handling any errors when running `ollama list`.

