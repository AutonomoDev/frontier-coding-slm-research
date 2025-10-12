# Thinking...
# We need to output a bash script only, no markdown. The script defines function _ollama_completions. Implementation: uses COMP_WORDS[0] and [1] check. Use _get_comp_words_by_ref -n : cur prev; fallback. Parse ollama list, skip header, get first column. Build array of models. Filter matches. Use compgen -W.
# 
# We need to ensure no errors: if ollama command not found, return empty completions.
# 
# Edge: when cur is empty, we list all. Should sort.
# 
# Also need to ensure __ltrim_colon_completions called after setting COMPREPLY.
# 
# Also need to register at end: complete -F _ollama_completions ollama.
# 
# Implement.
# 
# Potential script:
# 
# 
# _ollama_completions() {
#     # Ensure this is triggered only for "ollama run"
#     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
# 
#     # Retrieve current word and previous word, handling colons
#     _get_comp_words_by_ref -n : cur prev 2>/dev/null
#     # If _get_comp_words_by_ref not available, fallback
#     if [[ -z "$cur" ]]; then
#         cur="${COMP_WORDS[COMP_CWORD]}"
#         prev="${COMP_WORDS[COMP_CWORD-1]}"
#     fi
# 
#     # Verify ollama binary exists
#     if ! command -v ollama &>/dev/null; then
#         COMPREPLY=()
#         __ltrim_colon_completions "$cur"
#         return
#     fi
# 
#     # Obtain list of installed models
#     mapfile -t all_models < <(ollama list 2>/dev/null | awk 'NR>1{print $1}')
# 
#     # If no models, exit
#     if [[ ${#all_models[@]} -eq 0 ]]; then
#         COMPREPLY=()
#         __ltrim_colon_completions "$cur"
#         return
#     fi
# 
#     # Generate completions
#     local -a matches
#     if [[ -n "$cur" ]]; then
#         matches=($(compgen -W "${all_models[*]}" -- "$cur"))
#     else
#         matches=("${all_models[@]}")
#     fi
# 
#     COMPREPLY=($(printf "%s\n" "${matches[@]}" | sort))
#     __ltrim_colon_completions "$cur"
# }
# complete -F _ollama_completions ollama
# 
# 
# Check for proper syntax. We should include array length. Also use `compgen -W` properly: `compgen -W "${all_models[*]}" -- "$cur"`.
# 
# But the `-W` expects a string. Might be fine.
# 
# Alternatively, we can do:
# 
# 
# COMPREPLY=($(compgen -W "${all_models[*]}" -- "$cur"))
# 
# 
# The above is fine.
# 
# Need to handle sorting: we already sort.
# 
# Also ensure we set COMPREPLY to empty array if no matches.
# 
# Edge: We call __ltrim_colon_completions after setting COMPREPLY. That is required.
# 
# But we call it after returning in error cases too; we need to call in all flows. We must ensure we always call __ltrim_colon_completions before return.
# 
# We already call at end.
# 
# In the error case we call it and return.
# 
# We should not call __ltrim_colon_completions after we returned, but we return after calling. Good.
# 
# We also should check for _get_comp_words_by_ref -n : returns cur and prev. If this command not available, we fallback. In fallback we set cur and prev.
# 
# Edge: In fallback we used ${COMP_WORDS[COMP_CWORD]} and ${COMP_WORDS[COMP_CWORD-1]}. That should work.
# 
# Now final script. Ensure no stray spaces.
# 
# Let's produce final answer.
# ...done thinking.

_ollama_completions() {
    # Activate only for the exact command "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get the current and previous word, handling colons correctly
    _get_comp_words_by_ref -n : cur prev 2>/dev/null
    # Fallback if _get_comp_words_by_ref is unavailable
    if [[ -z "$cur" ]]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Ensure the ollama binary exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        __ltrim_colon_completions "$cur"
        return
    fi

    # Retrieve the list of installed models, skipping the header line
    mapfile -t all_models < <(ollama list 2>/dev/null | awk 'NR>1{print $1}')
    if [[ ${#all_models[@]} -eq 0 ]]; then
        COMPREPLY=()
        __ltrim_colon_completions "$cur"
        return
    fi

    # Generate completions that match the current input
    if [[ -n "$cur" ]]; then
        COMPREPLY=($(compgen -W "${all_models[*]}" -- "$cur"))
    else
        COMPREPLY=("${all_models[@]}")
    fi

    # Sort the suggestions for a consistent order
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Ensure colon handling works correctly
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
