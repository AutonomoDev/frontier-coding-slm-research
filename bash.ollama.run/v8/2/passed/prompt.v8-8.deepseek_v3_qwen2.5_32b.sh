#!/bin/bash

# Function for ollama run command completion.
_ollama_run_completion() {
    local cur prev words cword models

    # Detect the exact position of 'run' in COMP_WORDS array
    local run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when the cursor is at 'ollama run <TAB>'
    if [[ $COMP_CWORD -ne $((run_index + 1)) || $run_index -eq -1 ]]; then
        COMPREPLY=()
        return
    fi

    # Save and restore COMP_WORDBREAKS to handle colons correctly
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word break characters

    # Retrieve model names, handling variable whitespace
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Restore COMP_WORDBREAKS before returning
    COMP_WORDBREAKS="$old_wb"

    # Prepare the current word for completion
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Fallback in case the helper function is unavailable
        eval "cur=\"\${COMP_WORDS[COMP_CWORD]}\""
    }

    # Generate completions using compgen to safely match prefixes
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

# Register completion for 'ollama run' command
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Handling Word Break Characters (Colon Handling)**:
#   The `COMP_WORDBREAKS` variable is modified to exclude colons (`:`) temporarily during completion, ensuring that words containing colons are treated as single entities.
#
#2. **Position Detection**:
#   The script dynamically locates the index of `"run"` within the command line arguments (`COMP_WORDS`). Completion only triggers when the current word (cursor position) immediately follows `"run"` in the command.
#
#3. **Model Name Retrieval**:
#   The `ollama list` output is parsed robustly using `awk` to extract model names from the first column, even if there's variable whitespace between columns.
#
#4. **Fallback for Helper Function**:
#   If `_get_comp_words_by_ref` isn't available (e.g., in older environments), a fallback method directly accesses `$COMP_WORDS` to determine the current word (`cur`) being completed.
#
#5. **Safe Completion Generation**:
#   `compgen` is used with `-W` for prefix matching, avoiding potential issues from special characters or regex misuse.
#
#6. **No Filename Fallback**:
#   The completion function registers via `complete -F`, ensuring no unintended fallback to filename completions (no `-o default`).
#
#This script ensures robust handling of colons in model names and dynamic detection of command positions for accurate auto-completion.

