# [[HUMAN COMMENTED-OUT]]
#以下は、`ollama run <model>`のためのbash-completionスクリプトです。

# ollama_run_completion.sh

# Check if _get_comp_words_by_ref is available, otherwise fallback to manual word extraction
if ! type -t _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref() {
        local exclude cur_ words_ cword_
        if [ "$1" = "-n" ]; then
            exclude=$2
            shift 2
        fi
        __git_reassemble_comp_words_by_ref "$exclude"
        cur_=${COMP_WORDS[COMP_CWORD]}
        if [ $# -ge 1 ]; then
            eval $1=\$cur_
        fi
        if [ $# -ge 2 ]; then
            eval $2=\${COMP_WORDS[COMP_CWORD-1]}
        fi
    }
fi

_ollama_run_completion() {
    local cur prev opts models sorted_models

    # Extract current and previous words
    _get_comp_words_by_ref -n : cur prev

    # Check if we are completing the 'ollama run' command
    if [[ "$prev" != "run" || "${COMP_WORDS[0]}" != "ollama" ]]; then
        return
    fi

    # Get the list of models from ollama list
    models=$(ollama list 2>/dev/null)
    if [ -z "$models" ]; then
        return
    fi

    # Split models into an array (assuming space-separated output)
    IFS=$'\n' read -rd '' -a models_array <<<"$models"

    # Filter and sort models based on the current word being completed
    sorted_models=()
    for model in "${models_array[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            sorted_models+=("$model")
        fi
    done
    IFS=$'\n' sorted_models=($(sort <<<"${sorted_models[*]}"))
    unset IFS

    # Generate the completion options
    COMPREPLY=()
    if [ ${#sorted_models[@]} -eq 1 ]; then
        COMPREPLY+=( "${sorted_models[0]}" )
    else
        for model in "${sorted_models[@]}"; do
            COMPREPLY+=( "$model" )
        done
    fi
}

# Attach the completion function to ollama run
complete -F _ollama_run_completion ollama run

### インストール方法

# [[HUMAN COMMENTED-OUT]]
#以下の行を `.bashrc` に追加して、即座に有効化します。
#
#```bash
#source /path/to/your/ollama_run_completion.sh
#```
#
#これで `ollama run <Tab>` を押すと自動的に補完が行われるようになります。

