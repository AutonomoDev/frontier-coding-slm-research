# Bash completion for ollama command
_ollama() {
    local cur prev opts

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        run)
            # Fetch available models from 'ollama list', filter errors, and split into array
            if ! models=$(ollama list 2>/dev/null); then
                return
            fi

            IFS=$'\n' read -r -d '' -a model_list <<< "$models"
            COMPREPLY=( $(compgen -W "${model_list[*]}" -- "$cur") )
            ;;
    esac
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# **Installation Instructions:**
# 
# 1. **Source the script in your shell:**  
#    Add the following line to your `~/.bashrc` or equivalent:
#    source /path/to/this/script.sh
# 
# 2. **Activate immediately (optional):**
#    Run:
#    . /path/to/this/script.sh
# 
# **Notes:**  
# - The script handles errors by redirecting stderr to `/dev/null` during `ollama list`.
# - Completion is triggered only for the `run` subcommand of `ollama`.
