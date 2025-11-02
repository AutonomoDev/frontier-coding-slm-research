# [[HUMAN COMMENTED-OUT]]
# Here is a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies:
_ollama_run() {
  local -a ollama_models=( $(ollama list) ) # populate an array with model names from "ollama list"
  COMPREPLY=()                              # initialize empty completion list
  if [[ ${#COMP_WORDS[@]} == 3 ]]; then    # check if the current word is a model name prefix
    for model in "${ollama_models[@]}"; do # loop through each available model name
      [[ "$model" == "$2"* ]] && COMPREPLY+=("$model") # add matching model names to completion list
    done
  fi
}
complete -F _ollama_run ollama run  # register the completion function for "ollama run"
# [[HUMAN COMMENTED-OUT]]
# Installation instructions:
# 
# 1. Save this script to a file, e.g., `~/.bash_completion`.
# 2. Source the script in your shell's rc file, e.g., `source ~/.bash_completion` in `.bashrc`.
# 3. Restart your shell or reload its configuration for the changes to take effect.
# 4. You can now use the completion by typing `ollama run <Tab>` or partially typing a model name.
