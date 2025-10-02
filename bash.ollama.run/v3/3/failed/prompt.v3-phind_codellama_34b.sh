# [[HUMAN COMMENTED-OUT]]
#Here is your working bash-completion script for `ollama run <model>`:

# Bash completion for "ollama" command
_ollama()
{
    local cur prev models
    _get_comp_words_by_ref -n : cur prev

    # Triggering condition: must be completing a model after `run`
    if [[ $prev != "run" || $cur == * ]] ; then
        return 0
    fi

    # Retrieve list of models and sort
    local model_list_raw=$(ollama list 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return 0 # Graceful failure: if `ollama list` fails, return no completions
    fi
    models=($model_list_raw)
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS

    # Perform prefix-based filter and generate completion reply
    local model
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    return 0
}
complete -F _ollama ollama

## [[HUMAN COMMENTED-OUT]]
#To install/activate the script:
#
#1. Save the above script into a file, e.g., `ollama_completion.bash`.
#2. Open your `.bashrc` in a text editor and append the following line at the end of the file:
#```bash
#source /path/to/ollama_completion.bash
#```
#   Replace `/path/to/ollama_completion.bash` with the actual path to the script.
#3. Restart your terminal or run `source ~/.bashrc` in your current terminal to activate the completion script.

