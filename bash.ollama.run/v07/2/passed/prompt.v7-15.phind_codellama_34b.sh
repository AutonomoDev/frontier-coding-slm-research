# [[HUMAN COMMENTED-OUT]]
#Below is a Bash completion script for the `ollama run` command:

_ollama_run_completion() {
    # Only complete if the current word is immediately after the "run" subcommand
    local run_index=$(($COMP_CWORD - 1))
    [[ ${COMP_WORDS[run_index]} != "run" ]] && return

    # Save and remove colon from COMP_WORDBREAKS to handle model names with colons
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${old_wb//:}

    # Get a list of all models, skipping the header line and using awk to parse the first column
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Restore the original word breaks
    COMP_WORDBREAKS=$old_wb

    # If we got a list of models, filter them by the current word and set the completions
    if [[ -n $models ]]; then
        COMPREPLY=( $(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}" 2>/dev/null) )
    fi

    # Remove duplicates and exit
    compopt -o nospace 2>/dev/null
} && complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script provides autocompletion suggestions for model names when a user types `ollama run` followed by the `<TAB>` key. It uses the `bash-completion` framework and is self-contained, so it can be sourced (e.g., `source my_script.sh`) to enable the functionality.

