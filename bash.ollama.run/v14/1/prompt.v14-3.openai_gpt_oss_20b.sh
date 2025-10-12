#!/usr/bin/env bash

# Thinking...
# We need to output a Bash completion script following instructions. It should be a function `_ollama_completions()` and register complete -F. We must check COMP_WORDS[0] and [1] correctly. Use _get_comp_words_by_ref -n : cur prev. Use __ltrim_colon_completions at end. Parse ollama list. Use compgen to filter.
# 
# We need robust: handle missing ollama, no models, errors.
# 
# Let's craft script.
# 
# Important: Must include inline comments explaining critical sections. Use production-ready.
# 
# Ok, output only Bash code, no markdown.
# 
# We'll produce:
# 
# _ollama_completions() {
#     # Ensure we only run for 'ollama run'
#     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
# 
#     # Get current word and previous word, preventing colon splitting
#     _get_comp_words_by_ref -n : cur prev 2>/dev/null || {
#         # Fallback if _get_comp_words_by_ref is not available (e.g., non- bash completion env)
#         cur="${COMP_WORDS[COMP_CWORD]}"
#         prev="${COMP_WORDS[COMP_CWORD-1]}"
#     }
# 
#     # Verify 'ollama' executable exists
#     command -v ollama &>/dev/null || { COMPREPLY=(); return; }
# 
#     # Retrieve model list from 'ollama list', skipping header and extracting first column
#     mapfile -t _models < <(
#         ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'
#     ) || { COMPREPLY=(); return; }
# 
#     # If no models were found, exit
#     if (( ${#_models[@]} == 0 )); then
#         COMPREPLY=()
#         return
#     fi
# 
#     # Generate completion candidates matching the current prefix
#     COMPREPLY=( $(compgen -W "${_models[*]}" -- "$cur") )
# 
#     # Adjust for colon prefixes so that completions after a colon are shown
#     __ltrim_colon_completions "$cur"  # MUST be called
# 
#     return
# }
# 
# # Register the completion function for 'ollama'
# complete -F _ollama_completions ollama
# 
# 
# Check: we used `mapfile` - works bash 4+. Might use while read.
# 
# Edge: We must ensure _get_comp_words_by_ref is available; but we can fallback.
# 
# Also, we call __ltrim_colon_completions after setting COMPREPLY.
# 
# We need to be careful: The call to __ltrim_colon_completions expects the current word; it modifies COMPREPLY. That's fine.
# 
# Potential issue: `__ltrim_colon_completions "$cur"` may not exist in all shells, but assumption.
# 
# We might also ensure that `_get_comp_words_by_ref` might fail; but we provided fallback.
# 
# All good.
# 
# We need to ensure `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run".
# 
# Ok. Output only code.
# 
# Let's produce.
# ...done thinking.

_ollama_completions() {
    # -------------------------------------------------------------------------
    # 1️⃣ Only activate for the specific command "ollama run"
    # -------------------------------------------------------------------------
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # -------------------------------------------------------------------------
    # 2️⃣ Get the current and previous word, preventing Bash from splitting on ':'
    # -------------------------------------------------------------------------
    _get_comp_words_by_ref -n : cur prev 2>/dev/null || {
        # Fallback for environments where _get_comp_words_by_ref is unavailable
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # -------------------------------------------------------------------------
    # 3️⃣ Verify that the 'ollama' executable exists
    # -------------------------------------------------------------------------
    command -v ollama &>/dev/null || { COMPREPLY=(); return; }

    # -------------------------------------------------------------------------
    # 4️⃣ Retrieve model names from 'ollama list', skipping the header line
    #    and extracting only the first column (the model name)
    # -------------------------------------------------------------------------
    local -a _models
    mapfile -t _models < <(
        ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'
    ) || { COMPREPLY=(); return; }

    # If there are no models, nothing to complete
    if (( ${#_models[@]} == 0 )); then
        COMPREPLY=()
        return
    fi

    # -------------------------------------------------------------------------
    # 5️⃣ Generate completion candidates that match the current prefix
    # -------------------------------------------------------------------------
    COMPREPLY=( $(compgen -W "${_models[*]}" -- "$cur") )

    # -------------------------------------------------------------------------
    # 6️⃣ Adjust for colon prefixes so that completions after ':' are shown
    # -------------------------------------------------------------------------
    __ltrim_colon_completions "$cur"  # MUST be called for proper display

    return
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama
