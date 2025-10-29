# Bash completion script for 'ollama run' command.
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get cur/prev words by reference. -n : option sets cur to the part after the colon.
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists and parse models.
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then COMPREPLY=(); return; fi

    # Generate completions with compgen.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions using printf and sort.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Fix colon completions with __ltrim_colon_completions.
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
# [[HUMAN COMMENTED-OUT]]
# Note that this script assumes that the `ollama` command is available in your system's PATH, and that you have permission to run it. Also, the script uses the `awk` command, which may not be installed on all systems by default. If you don't have access to the `awk` command, you can modify the script to use a different tool for parsing the output of the `ollama list` command.
