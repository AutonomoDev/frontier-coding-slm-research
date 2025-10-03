# [[HUMAN COMMENTED-OUT]]
#Here's the correct Bash completion script:

```bash
_ollama() {
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # only complete 'run' subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    # get list of models for completion
    COMPREPLY=($(ollama list --raw | _get_comp_words_by_ref -n : -c -o ' ' 2>/dev/null | {
        read header
        while IFS='' read -r line; do
            [[ "$line" ]] && printf '%s\n' "${line%% *}"
        done
    }))
    
    # strip colon from model names
    __ltrim_colon_completions "$cur"

    return 0
}
complete -F _ollama ollama
