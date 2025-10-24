# Thinking...
# We need to produce a bash completion script for "ollama run" that fetches model names via "ollama list" and handles colons. Must modify COMP_WORDBREAKS.
# 
# Structure:
# 
# - function _ollama_run_completions
# - inside: store old=${COMP_WORDBREAKS}; then remove colon: COMP_WORDBREAKS=${COMP_WORDBREAKS//:/} ; use _get_comp_words_by_ref -n : cur prev; restore COMP_WORDBREAKS=$old
# - then check [[ "${COMP_WORDS[1]}" == "run" ]] else return
# - Then generate list of model names: using e.g., mapfile -t models < <(ollama list | awk 'NR>1{print $1}')? But header line contains columns; first column may have spaces. Use awk 'NR>1{print $1}' but first column can contain spaces? The sample: "codegemma:7b" is first token. Works.
# - Then use COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") ) ; or better: local -a comps; comps=($(compgen -W "${models[*]}" -- "$cur")); COMPREPLY=("${comps[@]}")
# 
# Edge: we should use _filedir etc? no.
# 
# Make sure _get_comp_words_by_ref is available. That function comes from bash-completion.
# 
# Also handle no models.
# 
# The script: we will use comment lines.
# 
# Make sure to register: complete -F _ollama_run_completions ollama
# 
# Also may need to ensure that _get_comp_words_by_ref is defined; but rely on system.
# 
# The script should be robust; using local variables.
# 
# Let's craft:
# 
# ```bash
# _ollama_run_completions() {
#     local cur prev
#     # Save original word breaks
#     local old_wc="$COMP_WORDBREAKS"
#     # Temporarily remove colon from word breaks
#     COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#     # Reparse words, ignoring colon as separator
#     _get_comp_words_by_ref -n : cur prev
#     # Restore original word breaks
#     COMP_WORDBREAKS="$old_wc"
# 
#     # Only provide completions for 'ollama run'
#     if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#         return
#     fi
# 
#     # Get model names from 'ollama list'
#     local models
#     if ! models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}'); then
#         return
#     fi
# 
#     COMPREPLY=($(compgen -W "$models" -- "$cur"))
# }
# complete -F _ollama_run_completions ollama
# ```
# 
# We might want to set local -a arr; but not necessary.
# 
# Potential issues: capturing models into variable. If models contains spaces? But model names like "codellama:13b" contain no spaces. So okay.
# 
# Also need to ensure compgen -W expects a string; pass "$models" will join words into string; compgen will handle. Fine.
# 
# Better to use local -a arr; arr=($models) maybe.
# 
# But fine.
# 
# Edge: if models contains newline. compgen will interpret newlines as separators; good.
# 
# Also we need to use correct quoting.
# 
# Better: local -a model_list; mapfile -t model_list < <(ollama list 2>/dev/null | awk 'NR>1{print $1}'); COMPREPLY=( $(compgen -W "${model_list[*]}" -- "$cur") ); This uses mapfile.
# 
# But simpler.
# 
# Will produce script.
# 
# We need to include comment lines but no extraneous text.
# 
# Ok.
# ...done thinking.

# Bash completion for `ollama run` – dynamically fetches model names
# and handles names that contain colons (e.g., codellama:13b).

_ollama_run_completions() {
    local cur prev

    # Preserve the original word break settings.
    local old_wc="$COMP_WORDBREAKS"
    # Temporarily remove the colon from the word breaks so that
    # words containing ':' are not split.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # Re-parse the command line with the modified word breaks.
    _get_comp_words_by_ref -n : cur prev
    # Restore the original word break settings.
    COMP_WORDBREAKS="$old_wc"

    # Only provide completions when the second word is 'run'.
    [[ "${COMP_WORDS[1]}" != "run" ]] && return

    # Fetch the list of available models from `ollama list`.
    # The first column of the output contains the model name.
    local models
    if ! models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}'); then
        return
    fi

    # Generate the completion reply.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for the `ollama` command.
complete -F _ollama_run_completions ollama
