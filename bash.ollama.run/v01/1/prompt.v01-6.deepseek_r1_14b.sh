Thinking...
Okay, I need to create a bash-completion script for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list` without using any external dependencies.

First, I should understand how bash completion works. Typically, you write a function that populates the COMPREPLY array based on the current word and command line context. So, I'll need to check if the current command being completed starts with "ollama run".

Next, when the user types `ollama run` followed by a Tab, the script should suggest models. If they've started typing part of a model name, it should filter the suggestions to match that prefix.

I need to handle cases where `ollama list` might fail, like if the command isn't found or returns an error. In such cases, the completion should return nothing without breaking the shell.

The script shouldn't rely on any third-party tools. So, I'll parse the output using standard shell commands and string manipulation. I'll capture the output of `ollama list`, split it into lines (since models are listed one per line), and then process each line to extract model names.

I should check if the previous word is "run" because that's when the user expects a model name. So, in the completion function, I'll look at COMP_WORDS[COMP_CWORD-1] to see if it's "run".

Now, about handling the output of `ollama list`. If it's separated by whitespace or newlines, using tr to replace spaces with newlines and then splitting on lines should work. So, something like `tr -s '[:space:]'\n` would handle both cases.

For each word in the model list that matches the current prefix (the part the user has typed so far), I'll add it to COMPREPLY.

Putting it all together, the function will check if the command is `ollama run`, then fetch the models, filter them, and suggest completions. If `ollama list` fails, the script should return without setting COMPREPLY, thus providing no suggestions.

Finally, for installation, I'll create a file in `/etc/bash_completion.d/` or `~/.bash_completion.d/` with the function. Then, either source it immediately or re-login so that the shell recognizes the new completion.

I think that's all. Let me structure the script step by step.
...done thinking.

```bash
# bash-completion function for ollama run <model>
# Populate COMPREPLY with available models from 'ollama list'

_ollama_run_models() {
    # Check if we're completing after 'run'
    if [[ ${COMP_WORDS[COMP_CWORD-1]} != "run" ]]; then
        return
    fi

    local prefix=${COMP_WORDS[COMP_CWORD]}
    local models=()

    # Get the list of models, handle errors silently
    { ollama list 2>/dev/null; } | tr -s '[:space:]'\n | while read -r line; do
        models+=("$line")
    done

    # Filter models by prefix and suggest completions
    COMPREPLY=($(compgen -P "$prefix" -- ${models[@]}))
}

# Install instructions:
# Save this script to /etc/bash_completion.d/ollama-run-completion or ~/.bash_completion.d/ollama-run-completion
# Source it immediately with:
#   source /path/to/script.sh
```

