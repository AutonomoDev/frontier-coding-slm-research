# A more robust and complete ollama completion function
_ollama_completion() {
    # Initialize COMPREPLY to an empty array. This is CRITICAL to prevent
    # leftover completions from other commands from appearing.
    COMPREPLY=()

    local cur_word prev_word
    cur_word="${COMP_WORDS[COMP_CWORD]}"
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Define the top-level subcommands for ollama
    local subcommands="run list pull rm ps help"

    # --- Main Logic ---

    # Case 1: Completing the subcommand itself (e.g., "ollama <TAB>")
    if [[ "$prev_word" == "ollama" ]]; then
        # Use compgen to filter the subcommands based on the current word
        COMPREPLY=( $(compgen -W "${subcommands}" -- "${cur_word}") )
        return 0
    fi

    # Case 2: Completing model names after "run", "cp", or "rm"
    # (e.g., "ollama run <TAB>" or "ollama rm mistral<TAB>")
    if [[ "$prev_word" == "run" || "$prev_word" == "cp" || "$prev_word" == "rm" ]]; then
        # Get model list using a robust parser (awk) and generate completions.
        # This is more efficient than populating an intermediate bash array.
        local models
        models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')
        COMPREPLY=( $(compgen -W "${models}" -- "${cur_word}") )
        return 0
    fi
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completion ollama