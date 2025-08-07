# Ensure we're running Bash
[[ "${BASH_VERSION:-0}" < '4.1' ]] && return 0

# If _get_comp_words_by_ref is defined, use it to populate cur and prev;
if type -t _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref cur prev || return 0
else
    # Manual fallback for older Bash versions or if _get_comp_words_by_ref is missing.
    COMPREPLY=( $( compgen -W '${COMP_WORDS[@]}' -- "$cur" ) )
fi

# Function for completing `ollama run <model>`
_ollama() {
  # Check if the command line context is ollama followed by run.
  [[ ${prev:-} != 'run' || ${COMP_WORDS[0]} != 'ollama' ]] && return 1

  # Capture full output of `ollama list` to a variable.
  local models=$(ollama list) || return 0

  # Filter out the model names that start with current word being completed as prefix.
  local filtered=()
  for model in $models; do
    [[ $model == "$cur"* ]] && filtered+=("$model")
  done

  # If there are matching models, sort them alphabetically and assign to COMPREPLY.
  if (( ${#filtered[@]} )); then
    IFS=$'\n' COMPREPLY=( $(sort <<<"${filtered[*]}") )
  fi
}

# Attach the function to `ollama` command.
complete -F _ollama ollama


#Installation:
#
#1. Save this script to a file, e.g., "~/.bash_completion".
#2. Add a line in your ~/.bashrc file to source the completion script after other completions have been loaded: `source ~/.bash_completion`.
#3. Reload Bash with `exec bash` or simply open a new terminal window.

