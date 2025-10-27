#!/usr/bin/env bash
# Bash completion script for the `ollama` command
# Provides model name completion for the `ollama run` subcommand,
# correctly handling model names that contain colons.

# Thinking...
# The user gave a detailed plan for v17, essentially a final prompt to produce a bash completion script. They want the AI to produce the code accordingly. The previous content is the prompt that would be used. The AI should respond with just the code, no markdown, no explanations. The code must follow the instructions.
# 
# Thus produce a single Bash script block: define _ollama_completions, check COMP_WORDS[1], handle colon by temporarily changing COMP_WORDBREAKS, get words, restore, fetch ollama list, generate completions, set COMPREPLY, call __ltrim_colon_completions, and register.
# 
# Include comments.
# 
# Make sure no extraneous whitespace or trailing commentary. Just code. Let's craft.
# 
# Potential pitfalls: use `COMP_WORDS[1]` as "run". The script runs when the user runs "ollama run". Should we check if COMP_WORDS[1] == "run"? Yes.
# 
# Also ensure we exit if not run. Must be the first action.
# 
# We should also check if command -v ollama exists; if not, return.
# 
# Implement fetch list:
# 
# ```
# local models
# models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
# ```
# 
# Set COMPREPLY:
# 
# ```
# COMPREPLY=( $(compgen -W "$models" -- "$cur") )
# ```
# 
# Call __ltrim_colon_completions "$cur".
# 
# Register: complete -F _ollama_completions ollama
# 
# Add comments accordingly.
# 
# Wrap in a script block.
# 
# Ensure no comments after registration? It can have comments too. But output only code.
# 
# Let's produce.
# ...done thinking.

_ollama_completions() {
    # 1. Context check: ensure we are completing `ollama run`
    #    The very first thing this function does is check the subcommand.
    #    If it is not `run`, we exit immediately to avoid interfering
    #    with other `ollama` subcommands or with filename completion.
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # 2. Colon handling – temporarily modify COMP_WORDBREAKS
    #    and re-parse the command line so that words containing ':' are
    #    treated as a single word. This ensures that when the user types
    #    something like `codellama:`, the word before it (`run`) is correctly
    #    identified as the previous word.
    local orig_breaks
    orig_breaks="$COMP_WORDBREAKS"                # Save original wordbreaks
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}         # Remove colon from wordbreaks
    _get_comp_words_by_ref -n : cur prev          # Re-parse words
    COMP_WORDBREAKS="$orig_breaks"                # Restore original wordbreaks

    # 3. Ensure the `ollama` binary is available
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # 4. Retrieve the list of installed models
    #    `ollama list` outputs a table; we skip the header line
    #    and extract only the first column (the model name).
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # 5. Generate completion suggestions for the current word
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # 6. Correctly display completions when a colon has been typed
    #    This final step ensures that the suggestions are shown
    #    properly after the colon character.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama
