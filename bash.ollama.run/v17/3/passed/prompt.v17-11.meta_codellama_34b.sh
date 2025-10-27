#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# This is a task description for an AI model, specifically, an LLM (Language Model) to generate a bash completion script for the `ollama run` command. The primary objective is to produce a robust, efficient, and correct completion script that handles model names containing colons. The core challenge is the colon problem, which causes Bash completions to fail when typing a colon after the `run` subcommand.
# 
# To address this challenge, the LLM needs to implement a two-part solution:
# 
# 1. Correctly parse the input by temporarily removing the colon from `COMP_WORDBREAKS` and using `_get_comp_words_by_ref -n :` to re-parse the command-line words.
# 2. Correctly display the suggestions by calling the bash-completion helper function `__ltrim_colon_completions "$cur"`.
# 
# The LLM must follow specific implementation requirements, including checking if the command is `ollama run`, generating a dynamic model list using `ollama list`, and registering the completion function for the `ollama` command. The output format must be a single contiguous block of Bash code with detailed inline comments explaining complex parts.
# 
# To ensure correctness, the generated script must meet certain requirements, such as checking `COMP_WORDS[1]` to confirm the subcommand is `run` and exiting otherwise, implementing `COMP_WORDBREAKS` modification and restoration, using `_get_comp_words_by_ref -n :` to get `cur` and `prev`, parsing `ollama list` output correctly (skipping the header), calling `__ltrim_colon_completions "$cur"` as the last step after setting `COMPREPLY`, and consistently containing only Bash code and its internal comments.
# 
# The final verification checklist includes all of these requirements, ensuring that the generated script is production-quality and meets all specifications.

# Bash completion script for 'ollama run' command
# Handles model names containing colons correctly

_ollama_completion() {
    local cur prev words cword
    
    # Check if the subcommand is 'run', exit otherwise
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    
    # Save original COMP_WORDBREAKS and remove colon temporarily
    # This prevents Bash from breaking completion at colons in model names
    local original_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
    
    # Re-parse command line with colon as non-breaking character
    # -n : tells the function to treat colon specially
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$original_wordbreaks"
    
    # Generate model list from ollama list command
    # Skip the header line (NAME...) and extract first column (model names)
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    
    # Trim colon-prefixed portions from completions for proper display
    # This is critical for handling model names with colons
    __ltrim_colon_completions "$cur"
    
    return 0
}

# Register the completion function for the ollama command
complete -F _ollama_completion ollama
