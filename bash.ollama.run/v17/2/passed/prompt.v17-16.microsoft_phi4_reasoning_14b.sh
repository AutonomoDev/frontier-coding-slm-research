#!/bin/bash
# Bash completion script for the "ollama run" command.
_ollama_completions() {
    # CRITICAL CONTEXT CHECK: Ensure we are completing an "ollama run" invocation.
    # COMP_WORDS[1] should be exactly "run". If not, exit immediately to avoid interfering with other commands.
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # TWO-PART COLON FIX:
    # 1. Save the original COMP_WORDBREAKS so that we can restore it after processing.
    local orig_comp_wordbreaks="${COMP_WORDBREAKS}"
    # Remove the colon (:) from COMP_WORDBREAKS to prevent it from splitting model names like "codellama:13b".
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # Re-parse the command-line input using _get_comp_words_by_ref with a colon as a delimiter.
    # This correctly identifies the current word ($cur) and the previous one ($prev) even when colons are present.
    _get_comp_words_by_ref -n : cur prev
    # Immediately restore COMP_WORDBREAKS to its original state after re-parsing.
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Verify that the "ollama" command is available on the system.
    if ! command -v ollama &>/dev/null; then
        return 0
    fi

    # DYNAMIC MODEL LIST GENERATION:
    # Execute 'ollama list' to get available models. Skip the header line and extract only the first column (model names).
    local model_list
    model_list=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions based on the current word ($cur) using compgen with the dynamically built list.
    COMPREPLY=( $(compgen -W "$model_list" -- "$cur") )

    # FINAL STEP: Adjust displayed completions to handle colons correctly.
    __ltrim_colon_completions "$cur"
}

# Register _ollama_completions as the completion function for the "ollama" command.
complete -F _ollama_completions ollama
