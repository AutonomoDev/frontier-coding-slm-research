# Bash completion for 'ollama run' command
# =========================================

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get current word and previous word
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Parse models
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then COMPREPLY=(); return; fi

    # Completions and sorting
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    __ltrim_colon_completions "$cur"
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script uses the `complete` command to register a completion function for the `ollama run` command. The completion function is defined in the `_ollama_completions()` function, which performs the following steps:
# 
# 1. Checks if the current word is "ollama" and the previous word is "run". If not, it returns an empty array and exits the function.
# 2. Uses `local` to define variables for the current word (`cur`) and previous word (`prev`). These are used to generate completions based on the input.
# 3. Parses the output of `ollama list` into a scalar variable called `models`. This is done using a command substitution, which captures the output of the command and assigns it to a variable.
# 4. Checks if `models` is empty, and if so, returns an empty array and exits the function.
# 5. Uses `compgen` to generate completions for the current word (`$cur`). The `-W "$models"` option tells `compgen` to use the words in the `models` variable as completions.
# 6. Calls `__ltrim_colon_completions` on the `$cur` variable, which trims the prefix from the completions and returns them as a sorted array.
# 7. Returns the final list of completions using `COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))`. This sorts the completions and sets them as the output for the completion function.
# 
# The script then registers the `_ollama_completions` function as a completion function for the `ollama run` command using the `complete` command.
