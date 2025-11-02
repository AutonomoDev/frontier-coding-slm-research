Thinking...
Alright, I need to create a bash-completion script for the command 'ollama run <model>'. The goal is to dynamically list available models by parsing the output of 'ollama list'. Let me break down the requirements and figure out how to approach this.

First, the trigger condition: completions should only appear when the user types 'ollama run' and is completing after 'run'. So, I'll need to check if the current word being completed is at position COMP_CWORD where it's the third word (since 'run' is the second word). That means checking if COMP_CWORD equals 2.

Next, model retrieval. The script should invoke 'ollama list' once and capture its output into a variable. I can't pipe it directly into a loop because that creates a subshell and loses arrays. So, I'll store the output in a variable using command substitution or by redirecting stdout.

I need to handle both cases where models are printed one per line or separated by whitespace. Using tr to replace spaces with newlines will help split them correctly. Then, I can read each model name into an array.

For prefix filtering, I'll use the current word being completed (from COMP_WORDS) and compare it against each model name. If the model starts with that prefix, it should be included in the completions.

If 'ollama list' fails, the script should return without any completions and without showing errors. So, I'll store the output of 'ollama list' in a variable and check its exit status. If it's non-zero, just return.

Sorting is required for multiple matches. After filtering, I'll sort the COMPREPLY array alphabetically before setting it.

No external dependencies are allowed, so I'll use built-in commands like tr, readarray, and string manipulation.

Now, putting this together into a bash-completion function. The function will be called with each word as needed. Using 'complete -F' to attach this function to 'ollama'.

I need to make sure that the function doesn't output anything unless it's completing correctly. Also, handle cases where there are no matches by returning early.

Finally, I'll include brief installation instructions at the end, telling the user where to save the script and how to activate it.
...done thinking.

```bash
# Bash completion for ollama run <model>
ollama_complete() {
    # Check if we're completing after "run"
    if [[ "${COMP_WORDS[COMP_CWORD]}" != "run" ]]; then
        return
    }
    
    # Get the current word being completed (the model prefix)
    local prefix="${COMP_WORDS[COMP_CWORD]}"
    
    # Store output of ollama list in a variable
    local models=$(ollama list 2>/dev/null)
    local exit_code=$?
    
    # If ollama list failed, return without completions
    if [ $exit_code -ne 0 ]; then
        return
    }
    
    # Split the output into an array of model names (handles both formats)
    models=$(echo "$models" | tr ' ' '\n')
    
    # Read models into an array
    local -a model_array
    readarray -t model_array < <(printf '%s\n' "$models")
    
    # Filter models by the current prefix and collect matches
    local COMPREPLY=()
    for model in "${model_array[@]}"; do
        if [[ "$model" == "$prefix"* ]]; then
            COMPREPLY+=("$model")
        fi
    done
    
    # Sort matches alphabetically
    IFS=$'\n' COMPREPLY=(`printf '%s\n' "${COMPREPLY[@]}" | sort`)
    
    # Only suggest models if there are matches
    [[ ${#COMPREPLY[@]} -gt 0 ]] && return 0
}

complete -F ollama_complete ollama

# Installation: Save this script to your shell configuration file (e.g., ~/.bashrc)
# and add at the end:
# complete -F ollama_complete ollama
```

