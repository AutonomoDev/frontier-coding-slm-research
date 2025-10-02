# Define completion function for ollama run
_ollama() {
    # Manually set prev and cur if _get_comp_words_by_ref doesn't exist or fails
    if ! type -t _get_comp_words_by_ref >/dev/null || ! _get_comp_words_by_ref; then
        local cword words=()
        _init_completion -n : || return
        cword=$((cword-1))
        prev=${words[cword-1]}
        cur=${words[cword]}
    fi

    # Check if previous word is 'run' and command is 'ollama'
    [[ $prev == "run" && $COMP_LINE == ollama* ]] || return

    # Run ollama list and store output in a variable
    local olist=$(ollama list 2>/dev/null) || return

    # Filter models starting with current word as prefix and sort them
    local matches=$(for model in $olist; do [[ $model == "$cur"* ]] && echo "$model"; done | sort)

    # Populate COMPREPLY with sorted, matching results
    if [[ -n $matches ]]; then
        COMPREPLY=( $(compgen -W "$matches") )
    fi
}

# Wire the function to 'ollama' command
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
#To activate this script, save it as `/etc/bash_completion.d/ollama` and then source `/etc/bash_completion` in your bashrc or reload your shell:
#
#```bash
## echo "source /etc/bash_completion" >> ~/.bashrc
## source ~/.bashrc
#```

