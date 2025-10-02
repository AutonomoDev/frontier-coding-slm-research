_ollama_completions() {
    # Save original word breaks and remove colon from them
    local original_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Re-parse the command line with colons as part of a word
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks
    COMP_WORDBREAKS="$original_wordbreaks"

    # Check if we are completing the "run" subcommand
    if [[ "$prev" == "run" ]]; then
        # Generate model names by extracting the first column from ollama list output, excluding the header
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions using generated model names and current word
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
#This script is for a `ollama` command with a subcommand `run`. It first saves the current word break settings, removes colons from them, and then re-parses the current command line to ensure that words containing colons are treated as single words. This avoids issues with Bash's default behavior of breaking on colons.
#
#If the previous word is `run`, it will generate completions for model names by extracting the first column from the output of `ollama list` (excluding the header), providing these names as possible completions for the current word.
#
#Finally, it registers the function `_ollama_completions` to handle completions for the `ollama` command using the bash-completion framework's `complete` builtin.

