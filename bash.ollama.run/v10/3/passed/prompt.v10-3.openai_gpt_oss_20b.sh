# Thinking...
# We need to output only bash code. Let's produce the function and register.
#
# Edge cases: retrieving models from ollama list: we need to filter header. Use awk 'NR>1 {print $1}'. We'll use local variable for models. Use compgen -W "$models" -- "$cur". Ensure we restore COMP_WORDBREAKS. Use local for original. Also local variables cur prev models.
#
# The function definition: _ollama_completions() { ... }
#
# Check first argument COMP_WORDS[1] is run. If not, return. For that we need to reference COMP_WORDS[1] inside function; can use local or just index.
#
# We also need to call _get_comp_words_by_ref -n : cur prev to parse. We need to temporarily modify COMP_WORDBREAKS. Save original: local original_wbr="$COMP_WORDBREAKS". Then modify. After parsing, restore original.
#
# Then if prev equals "run" we generate completions. But careful: The previous word after adjusting? Since we re-parsed with -n :, the prev will be the previous word before current. For "ollama run codellama:" we expect prev to be "run". Good.
#
# We then retrieve models. Use local models=$(ollama list | awk 'NR>1 {print $1}').
#
# Then COMPREPLY=($(compgen -W "$models" -- "$cur")). Actually compgen outputs array; assign with parentheses.
#
# Edge: We need to use local COMPREPLY? But it's a special variable; we just assign.
#
# We should return 0.
#
# Ok. Let's write code with comments.
#
# ...done thinking.

# Bash completion function for `ollama` that dynamically completes model names, handling colons in names
_ollama_completions() {
    # Ensure we only handle the `run` subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return  # Not the `run` subcommand; exit early
    fi

    # --- Handle colons in word breaks --------------------------------------------
    # Save the original word break settings to restore later
    local original_wbr="$COMP_WORDBREAKS"

    # Temporarily remove ':' from word breaks so that `codellama:13b` is treated as one word
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line, ignoring ':' as a separator.
    # This populates `cur` (current word being typed) and `prev` (previous word).
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word break settings to avoid side effects on other completions
    COMP_WORDBREAKS="$original_wbr"

    # ---------------------------------------------------------------------------

    # Only generate completions if the previous word is "run"
    if [[ "$prev" == "run" ]]; then
        # Retrieve model names from `ollama list`, skipping the header line
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Use compgen to generate possible completions based on the current word
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama
