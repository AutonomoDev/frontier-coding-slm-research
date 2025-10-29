```bash
_ollama_completions() {
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    local cur prev
    _get_comp_words_by_ref -n : cur
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
``` 

