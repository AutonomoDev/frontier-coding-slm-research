# bash_completion for ollama run <model>
_ollama_run() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "$prev" == "run" ]]; then
        # Fetch available models by parsing ollama list output
        models=$(ollama list 2>/dev/null | awk 'NR>1{split($0,a," "); print a[1]}')
        
        COMPREPLY=( $(compgen -W "$models" -- $cur) )
    fi

}

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# Explanation:
# - **Function `_ollama_run`**: This function is triggered when the `ollama` command is being completed. 
#   - **Parsing Models**: It captures the current cursor word (`$cur`) and previous argument (`$prev`). If the previous argument is "run", it fetches available models by running `ollama list`. The output (excluding headers) is parsed to extract model names from each line, assuming the model name is the first field.
#   - **Completion Generation**: It uses `compgen` with `-W "$models"` to generate completions matching the current word (`$cur`).
# - **Silencing Errors**: Any errors during `ollama list` execution are ignored (redirected to `/dev/null`) to prevent shell breakage.
# - **Installation**: The completion function is attached to the `ollama` command using `complete`.
# 
# Usage:
# After sourcing this script, autocompletion for models in `ollama run <model>` will work as intended.
