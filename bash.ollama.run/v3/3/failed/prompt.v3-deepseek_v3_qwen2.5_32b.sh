# Bash completion for 'ollama run <model>'
_ollama_run_models() {
    # Determine the current word (cur) being completed
    local cur prev cword
    _get_comp_words_by_ref -n : cur prev || return 1

    # Check if the command is ollama and the previous argument was 'run'
    case "$prev" in
        run)
            ;;
        *)
            return 1
            ;;
    esac

    # Capture the output of ollama list into a variable
    local models_list
    if ! models_list=$(ollama list); then
        COMPREPLY=()
        return 0
    fi

    # Split the output into an array (assuming one model per line)
    IFS=$'\n' read -r -d '' -a models <<< "$models_list"

    # Filter, sort, and build completions matching cur
    local matches=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the results alphabetically before providing them
    IFS=$'\n' matches_sorted=($(sort <<<"${matches[*]}"))
    unset IFS

    # Populate COMPREPLY with sorted matches using compgen for safety
    COMPREPLY=( $(compgen -W "${matches_sorted[*]}" -- "$cur") )
}

# Activate the completion function for ollama's 'run' subcommand
complete -F _ollama_run_models ollama

# To install, add the following to your .bashrc and source it:
# complete -F _ollama_run_models ollama
# Then, run `source ~/.bashrc` to activate.

