# [[HUMAN COMMENTED-OUT]]
# ### Solution Code

# bash-completion script for ollama command

_ollama_run() {
    local cur models

    # Get current word to complete (the one after 'run')
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch list of available models by parsing 'ollama list' output.
    # The first line is the header, so skip it and extract model names from remaining lines.
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models found (e.g., ollama command not available or list is empty), don't complete anything
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Filter model names based on current input (fuzzy match)
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Suppresses default completion message and highlights matches with color
    if [ ${#COMPREPLY[@]} -eq 1 ]; then
        compopt +o default
    fi
}

# Binds the function to complete 'ollama run' command.
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation
# 
# The provided Bash completion script is designed to enhance usability when working with the `ollama` CLI by offering dynamic completions for model names. Here's a breakdown of how it functions:
# 
# 1. **Completion Function (`_ollama_run`)**:
#    - **Current Word Detection**: The function starts by identifying which word in the command line requires completion (typically after `run`).
#    - **Fetching Model List**: It retrieves the available models by executing `ollama list`. The output is parsed with `awk`, skipping the header row and extracting only the model names from subsequent lines.
#    - **Completion Handling**:
#      - If no models are found, it leaves `COMPREPLY` empty to avoid offering completions (e.g., when `ollama` isn't installed or there's an error).
#      - Otherwise, it uses `compgen` to generate matches based on the current input (`cur`) against the retrieved model names.
#    - **Completion Optimization**: For single-match cases, it disables default completion messages for cleaner output.
# 
# 2. **Command Binding**:
#    - The script binds this completion function specifically to the `ollama run` command via `complete`, ensuring that only when `run` is part of the command line do model names get suggested.
# 
# This setup ensures efficient and dynamic completion without relying on external tools, making it portable across most POSIX-compliant environments.
