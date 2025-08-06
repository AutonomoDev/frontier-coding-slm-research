# Bash completion for `ollama run <model>`
_ollama_run_completion() {
    # safe get current and previous words with fallback
    local cur prev
    if ! (type _get_comp_words_by_ref >/dev/null 2>&1 && _get_comp_words_by_ref -n : cur prev); then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]:-}"
    fi

    # only trigger when the command is "ollama" and previous word is "run"
    # tolerate extra whitespace or other words before; we care that word before cursor is model arg after "run"
    if [[ "${prev}" != "run" ]]; then
        return 0
    fi
    # also ensure the command name is ollama (first word)
    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return 0
    fi

    # get list of models once
    local raw models_list model matches=()
    if ! raw="$(ollama list 2>/dev/null)"; then
        return 0  # failure: silent no completions
    fi
    # drop if empty
    [[ -z "$raw" ]] && return 0

    # split raw output into lines, trim and collect model names
    # assume model names appear one per line or are extractable as first token per line
    while IFS= read -r model; do
        # skip empty lines
        [[ -z "${model//[[:space:]]/}" ]] && continue
        # trim leading/trailing whitespace
        model="${model#"${model%%[![:space:]]*}"}"
        model="${model%"${model##*[![:space:]]}"}"
        models_list+=$'\n'"$model"
    done <<< "$raw"

    # filter by prefix (cur) and collect into array
    local IFS=$'\n'
    for model in $(printf '%s\n' "$models_list" | sort -u); do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # if no matches, nothing to do
    [[ ${#matches[@]} -eq 0 ]] && return 0

    # sort alphabetically (already sorted by upstream sort, but ensure)
    IFS=$'\n' sorted=($(printf '%s\n' "${matches[@]}" | sort))
    unset IFS

    # populate COMPREPLY
    COMPREPLY=( $(compgen -W "${sorted[*]}" -- "$cur") )
    return 0
}

# attach to ollama command
complete -F _ollama_run_completion ollama

# Installation / activation:
# Save this to ~/.ollama_completion.sh and add to your ~/.bashrc:
#   source ~/.ollama_completion.sh
# Then reload immediately with: source ~/.ollama_completion.sh

