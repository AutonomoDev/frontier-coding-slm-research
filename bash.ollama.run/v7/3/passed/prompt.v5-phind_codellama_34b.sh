#---BEGIN---###############################################

# This is the completion function for "ollama run" command.
_ollama_run_completion() {
    local cur prev words cword old_wb
    _get_comp_words_by_ref -n : cur prev words cword

    # Save original word breakers, remove colon from COMP_WORDBREAKS.
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${old_wb//:}

    # Find the "run" subcommand index and activate completion if appropriate.
    local run_index=$(for i in "${!words[@]}"; do if [[ ${words[i]} == run ]]; then echo $i; break; fi; done)
    if (( cword != run_index + 1 )); then return 0; fi

    # Get the list of models, parse it and remove header line.
    local model_list=($({ ollama list || echo ""; } | awk 'NR>1 {print $1}'))

    # Restore original word breakers.
    COMP_WORDBREAKS=$old_wb

    # Filter and generate completions based on current word.
    compopt -o nospace 2>/dev/null
    COMPREPLY=($(compgen -W "${model_list[*]}" -- "$cur"))
}

# Register the function for "ollama run" command.
complete -F _ollama_run_completion ollama

#---END---------------------------------------------------

# [[HUMAN COMMENTED-OUT]]
#This script is a proper Bash completion script for `ollama run` command as per given requirements. It provides auto-completion suggestions for model names after `ollama run`. It handles colons in model names correctly, and also avoids any common mistakes and pitfalls.

