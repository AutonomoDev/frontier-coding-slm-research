# Thinking...
# We need to output a bash completion script that defines a function for ollama run. We can parse `ollama list` output. We need to get the current word prefix from COMP_WORDS[COMP_CWORD]. For ollama run, the first word after command is model. So we need to detect when completing the second word (i.e., COMP_CWORD==2). But we need to allow partial typing. Use `COMPREPLY=($(compgen -W "$models" -- "$cur"))`.
# 
# We must fetch models via `ollama list` quietly, capture errors. Use `local models=$(ollama list 2>/dev/null)` but need to process lines. Use IFS=$'\n' read -r -a array. Then join to space for compgen.
# 
# Also handle if no models: COMPREPLY=().
# 
# Implement function _ollama_run_completion. Then register with complete -F.
# 
# Add minimal installation instructions: Save as /etc/bash_completion.d/ollama or ~/.bash_completion, then source via `source ~/.bash_completion` or add to ~/.bashrc.
# 
# Need to output only script with comments plus instructions. Use `#` comments.
# 
# Let's write.
# ...done thinking.

# Bash completion for `ollama run <model>`
# ----------------------------------------
# Save this file as /etc/bash_completion.d/ollama-run or
# ~/.bash_completion.d/ollama-run (create the directory if it does not exist).
#
# To enable it immediately, run:
#   source /etc/bash_completion.d/ollama-run
#   # or
#   source ~/.bash_completion.d/ollama-run
#
# Then type `ollama run <Tab>` to see the completions.

_ollama_run_completion() {
    local cur prev opts model_list IFS
    # Only complete the second word (the model name)
    if (( COMP_CWORD != 2 )); then
        return
    fi

    cur="${COMP_WORDS[COMP_CWORD]}"

    # Retrieve the list of available models from `ollama list`
    # Silently ignore any errors (command not found, etc.)
    model_list=$(ollama list 2>/dev/null) || return

    # If output is empty, give no completions
    if [[ -z "$model_list" ]]; then
        COMPREPLY=()
        return
    fi

    # Convert the list into a space-separated string for compgen.
    # `ollama list` may separate models by whitespace or newlines.
    # Use a subshell to preserve the original IFS.
    IFS=$'\n' read -r -d '' -a models < <(printf '%s\n' "$model_list" && printf '\0')

    # Use compgen to filter by the current prefix
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama
