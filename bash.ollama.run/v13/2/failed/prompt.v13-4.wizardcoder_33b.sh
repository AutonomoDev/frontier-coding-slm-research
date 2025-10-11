_ollama() {
    local cur prev words cword split

    _init_completion -s || return

    # The incorrect condition was here, it should be:
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    _get_comp_words_by_ref -n : cur prev words cword

    # Extract model names from the output of 'ollama list' command, excluding header line.
    COMPREPLY=( $( compgen -W "$(ollama list | tail -n +2)" -- $cur) )

    __ltrim_colon_completions "$cur"
} && complete -F _ollama ollama

