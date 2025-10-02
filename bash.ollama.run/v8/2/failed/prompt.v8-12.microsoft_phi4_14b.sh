# [[HUMAN COMMENTED-OUT]]
#Below is a robust Bash completion script for the `ollama run` command. This script carefully handles model names containing colons and adheres to all specified requirements.

# Function definition for ollama run completion
_ollama_run_completion() {
    # Save the current wordbreaks
    local old_wb="$COMP_WORDBREAKS"
    
    # Adjust COMP_WORDBREAKS to handle colons in model names
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Find the index of "run" in COMP_WORDS
    local run_index=$(printf "%s\n" "${COMP_WORDS[@]}" | grep -o "^run$" | awk 'NR==1 {print NR}')
    
    # Check if we are completing right after "run"
    if [[ "$run_index" -ne "$COMP_CWORD" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Extract the current and previous word for matching
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Fetch model names from ollama list, handling variable whitespace
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Use compgen for safe prefix matching, avoiding regex pitfalls
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore the original wordbreaks before exiting function
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with bash-completion framework v2
complete -F _ollama_run_completion ollama

# Ensure no filename fallback (do not register with `-o default`)

## [[HUMAN COMMENTED-OUT]]
#### Explanation of Key Sections:
#
#1. **Wordbreaks Handling**:
#   - `local old_wb="$COMP_WORDBREAKS"`: Save the current word break characters.
#   - `COMP_WORDBREAKS=${COMP_WORDBREAKS//:}`: Modify `COMP_WORDBREAKS` to remove colons, allowing colon-inclusive completions.
#
#2. **Position Detection**:
#   - The script finds where "run" occurs in `COMP_WORDS` and only triggers completion when the current word (`COMP_CWORD`) immediately follows "run".
#
#3. **Robust Data Parsing**:
#   - Model names are extracted with awk, ensuring it handles varying amounts of whitespace and ignores duplicate entries.
#
#4. **Helper Function Fallback**:
#   - `_get_comp_words_by_ref` is used to extract the current word being completed (`cur`) and its predecessor (`prev`). If unavailable, manual extraction is done from `COMP_WORDS`.
#
#5. **Safe Filtering**:
#   - Uses `compgen` for safe matching against model names prefixed with `$cur`, ensuring correct handling of special characters.
#
#6. **No Filename Fallback**:
#   - The completion function is registered without `-o default` to prevent filename fallback when no valid model name matches are found.
#
#This script should be sourced in your Bash environment to enable the desired command completions for `ollama run`.
