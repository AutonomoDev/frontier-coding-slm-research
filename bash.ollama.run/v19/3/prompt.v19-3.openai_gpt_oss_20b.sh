#!/bin/bash

# Thinking...
# We need to produce a Bash script code that defines _ollama_completions function and registers it. Must follow constraints.
# 
# Let's craft code.
# 
# Key points: _get_comp_words_by_ref -n : cur prev
# 
# Also call __ltrim_colon_completions "$cur" after sorting COMPREPLY.
# 
# We must not add unnecessary checks.
# 
# We must also check if ollama command exists.
# 
# Edge cases: If no models, set COMPREPLY=(); return.
# 
# We need to register via complete -F _ollama_completions ollama.
# 
# Also maybe call __ltrim_colon_completions before setting COMPREPLY? According to instructions: "AFTER setting and sorting COMPREPLY" – so after sort, we call __ltrim_colon_completions "$cur". But __ltrim_colon_completions modifies COMPREPLY in place? The typical usage: __ltrim_colon_completions "$cur" is used to trim the prefix, leaving only the suffix. It expects cur variable. The function will process COMPREPLY.
# 
# Ok.
# 
# Need to add comments explaining critical sections.
# 
# Let's write:
# 
# _ollama_completions() {
#     # Activate only for "ollama run"
#     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
# 
#     # Retrieve current word and previous word, handling colons
#     local cur prev
#     _get_comp_words_by_ref -n : cur prev
# 
#     # Ensure ollama binary is available
#     if ! command -v ollama &>/dev/null; then
#         COMPREPLY=(); return
#     fi
# 
#     # Get the list of models (first column from ollama list output)
#     local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#     if [ -z "$models" ]; then
#         COMPREPLY=(); return
#     fi
# 
#     # Generate completions for the current word
#     COMPREPLY=($(compgen -W "$models" -- "$cur"))
# 
#     # Sort the completions
#     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# 
#     # Remove the colon prefix from suggestions
#     __ltrim_colon_completions "$cur"
# }
# 
# # Register the completion function for the 'ollama' command
# complete -F _ollama_completions ollama
# 
# Make sure to include necessary comments.
# 
# We might also need to source bash completion functions? But __ltrim_colon_completions is provided by bash-completion library; we assume it's loaded.
# 
# The script should output only bash code, no markdown.
# 
# Thus final answer: just the code above.
# 
# Let's produce final.
# ...done thinking.

_ollama_completions() {
    # Activate only when the user types: ollama run
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Retrieve the current word and previous word, handling colons (e.g. "codellama:")
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Verify that the ollama binary exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=(); return
    fi

    # Extract the model names from the output of `ollama list`
    # Only the first column (model name) is needed; keep it as a single string
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=(); return
    fi

    # Generate completions for the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions alphabetically
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Remove any colon prefix from the suggestions
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama
