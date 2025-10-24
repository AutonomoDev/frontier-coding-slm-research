#The user wants a working bash completion script that’s free of dependencies. This requires a concise, functional script that implements the _ollama_run_completion function. I'll start by checking if the previous word matches 'run' (and if the command is 'ollama'). If those conditions match, I’ll run the completion. To prevent multiple calls, I’ll cache the result with a global variable and keep installation instructions to a minimum, focused on activation. Let’s get this script structured cleanly without unnecessary explanations.
#
#I need to ensure the function runs only once per call. I'll store the output of ollama list in a local variable and check if it's empty, returning if so. I'll use a loop to extract model names into an array. Then, for prefix matching, I'll filter the models and sort them. After that, I'll return the results using compgen to create completions. I'll be careful about edge cases, like model names containing special characters, but since they don’t, that should be fine. I'll also avoid repeating the command unnecessarily by utilizing a local cache.

# Bash-completion for `ollama run <model>`

_ollama_run_model_completion() {
    local cur prev

    # Safely get current & previous words
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Trigger only when the command is `ollama run …`
    [[ "${prev}" == "run" && "${COMP_WORDS[0]##*/}" == "ollama" ]] || return 0

    # Run `ollama list` exactly once and capture output
    local list
    if ! list="$(ollama list 2>/dev/null)"; then
        return 0   # graceful failure
    fi
    [[ -n "$list" ]] || return 0

    # Extract model names (first column)
    local models=()
    while read -r name _; do
        [[ -n "$name" ]] && models+=("$name")
    done <<<"$list"

    # Filter by prefix
    local matches=()
    for m in "${models[@]}"; do
        [[ "$m" == "$cur"* ]] && matches+=("$m")
    done
    [[ ${#matches[@]} -eq 0 ]] && return 0

    # Alphabetically sort and populate COMPREPLY
    IFS=$'\n' read -d '' -r -a COMPREPLY < <(printf '%s\n' "${matches[@]}" | sort -u)
}

# Wire the function to `ollama`
complete -F _ollama_run_model_completion ollama

# ---- Installation ----
# 1. Save this file as ~/.ollama-completion.sh
# 2. Add the line below to ~/.bashrc and reload or `source ~/.bashrc`:
#    source ~/.ollama-completion.sh

