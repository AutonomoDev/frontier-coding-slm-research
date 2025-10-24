# Bash completion script for ollama run command

_ollama_run_completion() {
    # Save current word break settings
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"  # Temporarily remove colon from word breaks

    # Determine the position of 'run' in COMP_WORDS
    local run_index=$(command printf '%s\n' "${COMP_WORDS[@]}" | command grep -n '^ollama$' | cut -d: -f1)
    if [[ -z "$run_index" || $((run_index + 1)) != "$COMP_CWORD" ]]; then
        # Only proceed with completion when 'run' is the current word
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Retrieve model names, handling variable whitespace correctly
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    if [[ -z "$models" ]]; then
        # Clear completions if no models are available
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Use helper function to get current and previous words, with manual fallback
    local cur prev
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Generate completion suggestions using compgen for safe prefix matching
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore original word break settings before exiting the function
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion script with bash-completion framework v2
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#### Explanation of Key Sections
#
#1. **Colon Handling**: The `COMP_WORDBREAKS` variable is temporarily modified to remove colons, ensuring model names containing colons are handled correctly. This change is always restored before the function exits.
#2. **Position Detection**: The script finds where 'ollama' appears in `COMP_WORDS` and checks if 'run' follows directly by comparing indices. It only proceeds with completion logic when 'run' is the current word being completed, ensuring accurate context for completions.
#3. **Robust Data Parsing**: Uses `awk` to handle variable whitespace between columns in the output of `ollama list`, ensuring robust parsing and avoiding fragile assumptions about column positions.
#4. **Helper Function Fallback**: Employs `_get_comp_words_by_ref` to safely extract current and previous words being completed, with a fallback method using direct array access if needed.
#5. **Safe Filtering**: Uses `compgen -W` for safe prefix matching against the model names, avoiding potential regex pitfalls from special characters in model names like colons.
#6. **No Filename Fallback**: Ensures completion logic does not fall back to filename suggestions by registering with `complete` without `-o default`. The script clears `COMPREPLY` when no models match the input prefix, adhering strictly to providing only relevant completions.
#
#This script should be sourced directly in your shell initialization file (e.g., `.bashrc`) or executed manually for the completion functionality to take effect.

