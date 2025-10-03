# Bash completion function for `ollama run` command
# Handles model names with colons correctly using COMP_WORDBREAKS manipulation
# Works with bash-completion framework v2

_ollama_run_completion() {
    # Save original COMP_WORDBREAKS to restore later
    local old_wb="$COMP_WORDBREAKS"

    # Find the position of "run" in COMP_WORDS
    local run_index=-1
    local i
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only provide completions when we're completing the model name after "run"
    if [[ $run_index -ne -1 && $COMP_CWORD -eq $((run_index + 1)) ]]; then
        # Remove colon from COMP_WORDBREAKS to allow colons in completions
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Get model names from ollama list, skip header line, extract first field
        # Use awk for robust whitespace handling
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Restore COMP_WORDBREAKS before any return/exit
        COMP_WORDBREAKS="$old_wb"

        # Use compgen for safe prefix matching
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Restore COMP_WORDBREAKS in case we didn't match the condition
        COMP_WORDBREAKS="$old_wb"
        # Clear COMPREPLY if not providing model completions
        COMPREPLY=()
    fi
}

# Register the completion function for `ollama`
# Do NOT use -o default to avoid filename completion interference
complete -F _ollama_run_completion ollama
