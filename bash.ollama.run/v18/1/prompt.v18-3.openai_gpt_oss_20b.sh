Thinking...
We need to produce bash script code only, with comments inline, following the steps. It should define function _ollama_completions, with checks, colons handling, parse, compgen, sorting, ltrim, and register. Ensure proper quoting. Use local variables. Use correct array assignment. When using compgen, need to quote properly. Avoid manual loops. Provide comments. Ensure no extraneous text. Output just code.

Edge: need to use $(...) for command substitution. For array assignment: models=($(...)). For sorting, we can use sort <<<"${models[*]}" but need to handle quoting; maybe use mapfile or readarray? Simpler: IFS=$'\n'; models=($(sort <<<"${models[*]}")); unset IFS.

Make sure to handle no ollama command gracefully: check command -v ollama.

Also _get_comp_words_by_ref may not exist if older bash. Use fallback.

Also ltrim colons function may not exist; call if type.

Then register complete -F _ollama_completions ollama.

All good.

Let's produce code.
...done thinking.

```bash
# Bash completion for "ollama run <model>"
_ollama_completions() {
    # Ensure we are completing "ollama run" and only the second argument
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Grab current word and previous word, handling colons
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Collect available models from "ollama list"
    local models=()
    if command -v ollama &>/dev/null; then
        # Skip header, keep only the first column (model names)
        models=( $(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') )
    fi

    # Sort models before generating completions
    if (( ${#models[@]} )); then
        IFS=$'\n' sorted=($(sort <<<"${models[*]}")); unset IFS
        models=("${sorted[@]}")
    fi

    # Generate completion list using compgen
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim any leading colon when inserting the completion
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for "ollama"
complete -F _ollama_completions ollama
```

