#以下は、`ollama run <model>` のための bash-completion スクリプトです。このスクリプトは、必要なすべての要件を満たしています。

# ollama run model completion
_ollama_run_model_completion() {
    local cur prev words cword split
    if [[ "${BASH_VERSION}" == 5.* ]]; then
        # Bash 5.x specific handling for COMP_WORDS and COMP_CWORD
        _get_comp_words_by_ref -n : cur prev words cword comp_line comp_point
    else
        # Fallback for older versions of bash
        local i
        for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
            if [ "$i" -eq "$COMP_CWORD" ]; then
                cur="${COMP_WORDS[i]}"
            fi
            if [ "$i" -eq "$(($COMP_CWORD-1))" ]; then
                prev="${COMP_WORDS[i]}"
            fi
        done
    fi

    # Check if the previous word is 'run' and the command is 'ollama'
    if [[ $prev != "run" || "${words[0]}" != "ollama" ]]; then
        return
    fi

    # Get the list of models using ollama list
    local model_list=$(ollama list 2>/dev/null)

    # Check if the list command was successful and not empty
    if [[ -z "$model_list" ]]; then
        return
    fi

    # Extract model names from the output
    local IFS=$'\n'
    models=($model_list)

    # Filter models that start with the current word being completed
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    # Sort the completions alphabetically
    IFS=$'\n' && COMPREPLY=($(sort <<<"${COMPREPLY[*]}")) && unset IFS
}

# [[HUMAN COMMENTED-OUT]]
# Attach the completion function to ollama run command
complete -F _ollama_run_model_completion ollama run

#### インストール方法
#以下の行を `.bashrc` に追加して、即座に有効化できます。
#
#```bash
#source /path/to/your/script.sh
#```
#
#例:
#
#```bash
#source ~/ollama-completion.sh
#```
#
#これで、`ollama run <Tab>` を押すと `ollama run` の後に続くモデル名が自動的に補完されるはずです。
#
