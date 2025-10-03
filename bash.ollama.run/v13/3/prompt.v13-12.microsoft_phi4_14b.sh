_ollama_complete_models() {
    local cur prev words cword

    _init_completion -n : || return

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        # Only activate completion when the command is `ollama run`
        return
    fi

    local models=()
    if ! models=( $(ollama list --format=json | jq -r '.[] | select(.name != null) | .name') ); then
        return
    fi

    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_complete_models ollama

# [[HUMAN COMMENTED-OUT]]
# This script ensures that the completion only activates when `ollama run` is used, handles colons in model names correctly by using `_get_comp_words_by_ref -n :`, and processes the output of `ollama list` to provide appropriate completions.
