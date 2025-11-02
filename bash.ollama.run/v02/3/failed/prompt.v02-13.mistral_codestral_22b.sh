#!/bin/bash

_ollama() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # If command is 'ollama run' and we are completing after 'run'...
    if [[ "${prev}" == "run" ]]; then
        # Capture the output of ollama list into a variable, ensuring no subshells get created.
        local -a models=()
        while IFS= read -r line; do
            models+=($line)
        done < <(ollama list 2>/dev/null || :)

        # Filter model names based on the current word being completed and assign to COMPREPLY.
        COMPREPLY=( $(compgen -W "${models[*]}" -- ${cur}) )

        # Sort completions alphabetically before returning them.
        mapfile -t COMPREPLY < <(printf "%s\n" "${COMPREPLY[@]}" | sort)
    fi
}

# Wire the completion function to ollama command.
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# To activate this script immediately, add it to your `.bashrc` file and source it:
# 
# 1. Open `~/.bashrc` in an editor (e.g., `nano ~/.bashrc`).
# 2. Append the provided script at the end of the file.
# 3. Save and close the file.
# 4. Run `source ~/.bashrc` to make changes effective immediately without needing to restart the shell.
