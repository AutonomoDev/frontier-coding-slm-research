#!/bin/bash
# This script provides bash completion for the `ollama run` command.

_ollama_run_completion() {
    # If the _get_comp_words_by_ref helper is not available, this completion will not
    # function correctly for model names with colons. It's a standard part of
    # the bash-completion package, which is recommended.
    if ! declare -F _get_comp_words_by_ref >/dev/null; then
        # Fallback to a basic implementation if the helper is missing.
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        if [[ "$prev" != "run" ]]; then
            return
        fi
        COMPREPLY=( $(compgen -W "$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')" -- "$cur") )
        return
    fi

    local cur prev
    # Temporarily remove ':' from word break characters for this function's scope.
    # This allows `_get_comp_words_by_ref` to treat "model:tag" as a single word.
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # The key to the solution: Re-parse the command line with custom rules.
    # The `-n :` tells it to NOT use the colon as a word separator.
    # This correctly sets `cur` and `prev` even after a colon is typed.
    _get_comp_words_by_ref -n : cur prev

    # Now that `prev` is reliable, we can use a simple and robust trigger.
    if [[ "$prev" != "run" ]]; then
        COMP_WORDBREAKS=$_old_wb # Restore and exit
        return
    fi

    # Get the list of installed models.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    if [[ -z "$models" ]]; then
        COMP_WORDBREAKS=$_old_wb # Restore and exit
        return
    fi

    # `compgen` generates suggestions based on the word list and the current word.
    # `mapfile` safely reads these suggestions line-by-line into the COMPREPLY array,
    # preventing issues with whitespace or special characters in model names.
    mapfile -t COMPREPLY < <(compgen -W "${models}" -- "${cur}")

    # IMPORTANT: Always restore the original COMP_WORDBREAKS.
    COMP_WORDBREAKS=$_old_wb
}

# Register the completion function for the `ollama` command.
# -o nosort: Prevents Bash from re-sorting our list.
# -o default: If our function returns no results, fall back to default completions (e.g., filenames).
complete -F _ollama_run_completion -o nosort -o default ollama