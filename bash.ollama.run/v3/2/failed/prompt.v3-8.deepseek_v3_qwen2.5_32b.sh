# Bash completion function for ollama run <model>
_ollama_run() {
    # Get current word and previous word (if using _get_comp_words_by_ref fails, fallback)
    local cur prev words cword
    if ! _get_comp_words_by_ref -n =: -c words cword; then
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi
    cur="${words[cword]}"
    prev="${words[cword-1]}"

    # Only complete after 'run' in ollama command
    if [[ "$prev" == "run" && "${words[0]}" == "ollama" ]]; then
        local models
        models=$(ollama list 2>/dev/null) || return

        # Extract model names (first column), filter by prefix, and sort
        local candidates=()
        while IFS=' ' read -ra line; do
            [[ ${line[0]} == "$cur"* ]] && candidates+=("${line[0]}")
        done <<< "$models"

        if [[ ${#candidates[@]} -gt 1 ]]; then
            IFS=$'\n' sorted=($(sort <<< "${candidates[*]}"))
            unset IFS
            COMPREPLY=( $(compgen -W "${sorted[*]}" -- "$cur") )
        else
            COMPREPLY=( $(compgen -W "${candidates[*]}" -- "$cur") )
        fi
    fi
}

# Wire up the completion function to ollama command
complete -F _ollama_run ollama

# Installation: Add this line to your .bashrc and restart terminal or source it:
# source /path/to/this/script.sh

