# Bash completion for `ollama run <model>`
# - Activates only for `ollama run <TAB>`
# - Runs `ollama list` exactly once per completion
# - Prefix-filters, sorts, and populates COMPREPLY
# - No external deps beyond Bash + coreutils (sort)

_ollama_run_model_completion() {
    # Keep ':' from being a word-break (models like "qwen2:7b")
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Extract current/previous words; fall back if helper is missing
    local cur prev
    if declare -F _get_comp_words_by_ref >/dev/null; then
        # -n : => don't treat ':' as a break
        _get_comp_words_by_ref -n : cur prev || {
            cur=${COMP_WORDS[COMP_CWORD]}
            prev=${COMP_WORDS[COMP_CWORD-1]}
        }
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Only trigger after `ollama run`
    local cmd=${COMP_WORDS[0]}
    if [[ $cmd != ollama || $prev != run ]]; then
        COMP_WORDSBREAKS=$_old_wb
        return 0
    fi

    # Retrieve models once
    local out
    if ! out=$(ollama list 2>/dev/null); then
        COMP_WORDSBREAKS=$_old_wb
        return 0
    fi
    [[ -n $out ]] || { COMP_WORDSBREAKS=$_old_wb; return 0; }

    # Parse first column (model names), skipping header/blank lines
    local models=()
    while IFS= read -r line; do
        [[ -z $line ]] && continue
        # Skip header line that typically starts with "NAME"
        [[ $line == NAME* ]] && continue
        # Take first whitespace-delimited token
        local name=${line%%[[:space:]]*}
        [[ -n $name ]] && models+=("$name")
    done <<< "$out"

    # Filter by prefix
    local matches=()
    local m
    for m in "${models[@]}"; do
        [[ $m == "$cur"* ]] && matches+=("$m")
    done
    [[ ${#matches[@]} -gt 0 ]] || { COMP_WORDSBREAKS=$_old_wb; return 0; }

    # Sort alphabetically and populate COMPREPLY
    local sorted=()
    while IFS= read -r m; do
        sorted+=("$m")
    done < <(printf '%s\n' "${matches[@]}" | sort -u)

    COMPREPLY=()
    # Use compgen on an already-sorted word list
    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${sorted[@]}")" -- "$cur") )

    # Restore word-breaks
    COMP_WORDSBREAKS=$_old_wb
}

# Wire it up to `ollama`
# -o nosort preserves our alphabetical order
# -o bashdefault/default lets normal completion pass through when we don't match
complete -F _ollama_run_model_completion -o nosort -o bashdefault -o default ollama

# --- Installation / Activation ---
# Save this file as: ~/.bash_completion.d/ollama-run-models.bash
# Then add this line to your ~/.bashrc (create the directory if needed):
#   [[ -r ~/.bash_completion.d/ollama-run-models.bash ]] && source ~/.bash_completion.d/ollama-run-models.bash
# Activate now (without restarting shell):
#   source ~/.bashrc
