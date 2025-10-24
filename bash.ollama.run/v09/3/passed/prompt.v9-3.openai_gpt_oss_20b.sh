#Thinking...
#We need to output only code, no commentary. Provide the script. Ensure we include comments inside code. Must produce a Bash completion script for ollama run. Use advanced pattern described. Use complete -F _ollama_completions ollama. Should be single contiguous block. Provide comments only inside code. Let's craft.
#
#We need to check for function _ollama_completions. Use _get_comp_words_by_ref -n : cur prev. Save old COMP_WORDBREAKS. Then get models via ollama list | awk 'NR>1 {print $1}'. Use compgen.
#
#Also maybe handle if no prev? Only when prev is "run". Provide comment about colon handling. Provide code.
#
#Add guard for function existence? Usually not needed. We'll just define.
#
#Wrap with #!/usr/bin/env bash? Not necessary for completion file but can include. Provide code comments. Provide a final line complete -F _ollama_completions ollama.
#
#Let's produce final code.
#...done thinking.

# Bash completion script for the `ollama` command, providing dynamic
# completions for model names after the `run` subcommand.
# This script handles model names that contain colons (e.g., "codellama:13b")
# by temporarily modifying the word-breaking characters.

# Function that generates completions for `ollama run`.
_ollama_completions() {
    # Preserve the original word-breaking characters.
    local _old_wb=${COMP_WORDBREAKS}

    # Remove ':' from the word break list so it is not treated as a separator.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line using the modified word breaks.
    # The `-n :` option tells the helper to ignore ':' as a separator.
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word-breaking characters to avoid side effects.
    COMP_WORDBREAKS=${_old_wb}

    # If the previous word is `run`, provide model name completions.
    if [[ "$prev" == "run" ]]; then
        # Dynamically fetch the list of available models.
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completion candidates.
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function with the `ollama` command.
complete -F _ollama_completions ollama
