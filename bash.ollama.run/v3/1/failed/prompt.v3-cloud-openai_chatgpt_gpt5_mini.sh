#!/usr/bin/env bash
# Bash completion for `ollama run <model>`
# - Activates only when completing the argument after `ollama run`
# - Calls `ollama list` exactly once and iterates over its captured output
# - Filters by prefix, sorts alphabetically, and populates COMPREPLY
# - Uses only bash builtins and coreutils (sort)
# - Gracefully does nothing if `ollama list` fails or returns empty

_ollama_run_models() {
    local cur prev cmd
    # Prefer helper if available; otherwise fall back to COMP_WORDS/COMP_CWORD
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        # -n : prevents word splitting on certain chars (safe default)
        if ! _get_comp_words_by_ref -n : cur prev 2>/dev/null; then
            cur="${COMP_WORDS[COMP_CWORD]:-}"
            prev="${COMP_WORDS[COMP_CWORD-1]:-}"
        fi
    else
        cur="${COMP_WORDS[COMP_CWORD]:-}"
        prev="${COMP_WORDS[COMP_CWORD-1]:-}"
    fi

    cmd="${COMP_WORDS[0]:-}"

    # Only provide completions when the command is `ollama` and the previous word is `run`
    [[ "$cmd" == "ollama" && "$prev" == "run" ]] || return 0

    # Run `ollama list` exactly once and capture output; on failure or empty output, exit gracefully
    local models_raw
    models_raw="$(ollama list 2>/dev/null)" || return 0
    [[ -z "${models_raw}" ]] && return 0

    # Split captured output into lines safely
    local lines
    readarray -t lines <<< "$models_raw"

    # Collect matches that start with the current prefix
    local model
    local matches=()
    for model in "${lines[@]}"; do
        # Trim leading/trailing whitespace
        model="${model#"${model%%[![:space:]]*}"}"
        model="${model%"${model##*[![:space:]]}"}"
        [[ -z "$model" ]] && continue
        # Prefix match per requirement
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # No matches -> nothing to complete
    [[ ${#matches[@]} -eq 0 ]] && return 0

    # Sort alphabetically
    local sorted
    IFS=$'\n' sorted="$(printf '%s\n' "${matches[@]}" | sort)"

    # Populate COMPREPLY using compgen on the sorted list
    COMPREPLY=( $(compgen -W "$sorted" -- "$cur") )

    return 0
}

# Attach completion function to `ollama`
complete -F _ollama_run_models ollama

# Installation / activation (example):
# Save this file, e.g. ~/.bash_completion.d/ollama
# Add to ~/.bashrc:   source ~/.bash_completion.d/ollama
# To activate immediately: source ~/.bash_completion.d/ollama
