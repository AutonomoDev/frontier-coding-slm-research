 # Bash Completion Function for 'ollama run <model>'

Here's a single Bash function that enables tab completion for the command `ollama run <model>`. This function is designed to handle various edge cases like when the `ollama` command is not available, if the model list is empty, and if there are colons in the input.

```bash
# Start of _ollama_completions function definition
_ollama_completions() {
    # Validate that COMP_WORDS[0] is 'ollama' and COMP_WORDS[1] is 'run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Fetch models using ollama list and store in a scalar string
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort COMPREPLY and trim colons
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
# Register the function for completion
complete -F _ollama_completions ollama
```
This script will work as expected in a Bash environment. It's designed to be integrated into the user's shell configuration file (such as `~/.bashrc` or `~/.bash_profile`) and provides tab completion for available Ollama models after typing `ollama run`.

