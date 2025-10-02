# Bash completion for ollama run <model> command
_ollama_run() {
    local cur prev words cword

    # Fallback if _get_comp_words_by_ref is missing or fails
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check triggering condition (previous word is 'run' and command is 'ollama')
    if [ "${prev}" = "run" ] && [ "${words[0]}" = "ollama" ]; then
        # Get model list and store it in a variable
        local models_output=$(ollama list) || return 0

        # Filter, sort, and populate COMPREPLY
        mapfile -t models < <(printf '%s\n' "${models_output}" | sort)
        COMPREPLY=($(compgen -W "$(printf "%s\n" "${models[@]}" | awk '$0 ~ "^'"$cur"'"')" -- "$cur"))
    fi
} && complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#Installation: Save the above script in a file (e.g., `/etc/bash_completion.d/ollama`) and source it in your shell or add `source /etc/bash_completion.d/ollama` to your `~/.bashrc` file, then reload your shell to activate the completion.

