# Bash completion script for `ollama run` command

_ollama_run_complete() {
  # Check if we are completing the 'run' subcommand of 'ollama'
  local cur prev words cword
  _init_completion -n : || return

  # Ensure that we're in the correct position: `ollama run <TAB>`
  if [[ ${#words[@]} -ne 2 || "${words[1]}" != "run" ]]; then
    return
  fi

  # Retrieve and parse available model names from 'ollama list'
  local models
  models=$(ollama list | awk 'NR>1 {print $1}' | tr '\n' ' ')

  # Filter suggestions based on the current word being typed (cur)
  COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
}

# Register the completion function for `ollama run`
complete -F _ollama_run_complete ollama

# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#
#- **Function Declaration**: The script defines a function `_ollama_run_complete` that implements the logic for autocompletion.
#
#- **Completion Initialization**: The `_init_completion` is called with `-n :` to ensure we're only working with completion variables (`COMP_WORDS`, `COMP_CWORD`, etc.) without any specific command context.
#
#- **Position Check**: It ensures that this completion function activates only when the user types something like `ollama run <TAB>`. This is done by checking if there are exactly two words and the second word is "run".
#
#- **Model Retrieval**: The script captures the output of `ollama list`, skips the first line (header), and extracts model names using `awk 'NR>1 {print $1}'`.
#
#- **Completion Filtering**: Uses `compgen` to filter and generate completion suggestions based on what the user has typed so far (`cur`). This ensures only matching models are suggested.
#
#- **Registering Completion**: The script uses `complete -F _ollama_run_complete ollama` to register this function specifically for the `ollama run` command.
#
#This setup guarantees that model names are correctly parsed, filtered, and presented without errors or unexpected behavior.

