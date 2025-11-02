
#!/bin/bash

_ollama_completion() {
    # Check if we're completing the first argument (i.e., 'run')
    if [[ "$COMP_CWORD" -eq 1 ]]; then
        COMPREPLY=(run)
        return
    fi

    # Check if we're completing the second argument (i.e., a model name)
    if [[ "$COMP_CWORD" -eq 2 ]]; then
        # Get the output of 'ollama list', filter it by the current word prefix, and put the results in an array
        local models=($(ollama list 2>/dev/null | grep "^$COMP_WORDS[*]"))
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$2") )
    fi
}

# Installation instructions:
# 1. Save this script as ~/.ollama_completion
# 2. Add the following line to your .bashrc or equivalent:
#      source ~/.ollama_completion
# 3. Reload your shell's configuration:
#      source ~/.bashrc
```

This script defines a function `_ollama_completion` that will be called by the Bash completion system when the user presses <Tab>. The function checks if we're completing the first argument (i.e., 'run') and, if so, suggests the 'run' command as the only possible completion. If we're completing the second argument (i.e., a model name), it gets the output of `ollama list` and filters it by the current word prefix using the `grep "^$COMP_WORDS[*]"` pattern. Finally, it puts the results in an array and passes them to `compgen` for further completion. If `ollama list` fails (e.g., command not found or error), the function silently returns no completions.

To install this script, save it as ~/.ollama_completion (or any other name you prefer) and add the following line to your .bashrc or equivalent:
```bash
source ~/.ollama_completion
```
Reload your shell's configuration by running `source ~/.bashrc` or equivalent, and you should now have working Bash completion for the `ollama run <model>` command.

