# [[HUMAN COMMENTED-OUT]]
# # Bash Completion Script for `ollama run`
#
#    This script provides completion suggestions for the `ollama run <model>` command, ensuring a smooth user experience when selecting from available models. The script is designed to:
#
#    - Only activate for `ollama run`.
#    - Handle colons in model names (e.g., `codellama:13b`).
#    - Parse the output of `ollama list` correctly, even if `ollama` command is not installed or no models are available.
#    - Complete only the model argument in `ollama run <model>`.
#
# Here's the complete Bash code with step-by-step comments:

# Define the completion function for ollama run
_ollama_completions() {
  # Check if the command is 'ollama run' and it's the model argument that needs completion
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return 0;
  [[ $COMP_CWORD -ne 2 ]] && return 0;

  # Handle colons in model names
  local cur prev
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Parse the output of 'ollama list' to get available models
  local models=()
  if command -v ollama &>/dev/null; then
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  fi

  # Generate completion suggestions
  IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

  # Fix colon handling for inserted completions
  if type __ltrim_colon_completions &>/dev/null; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register the completion function for 'ollama run'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Follow these steps to set up the script:
#
# 1. Copy the above code into your Bash profile (e.g., `~/.bashrc` or `~/.bash_profile`).
# 2. Source the Bash profile to apply the changes:
#    source ~/.bashrc
#    # OR
#    source ~/.bash_profile
# 3. Start using `ollama run` with completion suggestions for available models, even after colons (e.g., `codellama:`).
