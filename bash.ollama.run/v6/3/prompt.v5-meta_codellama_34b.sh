```bash
# Bash completion for ollama run

_ollama_run() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Targeted triggering: only activate when the previous word is "run"
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Precise parsing: extract model names from `ollama list` output
    local models
    while read -r line; do
        # Skip header and lines with colons (likely hashes, sizes, etc.)
        if [[ "$line" =~ ^NAME ]] || [[ "$line" == *:* ]]; then
            continue
        fi
        models+=("${line%%:*}")  # remove everything after first colon
    done < <(ollama list)

    # Contextual filtering: complete only model names starting with cur
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # No filename fallback: do not suggest filenames from current directory
    [[ $COMPREPLY ]] && return 0

    # Unique suggestions: remove duplicates
    COMPREPLY=($(printf '%s\n' "${COMPREPLY[@]}" | sort -u))
}
complete -F _ollama_run ollama
```

