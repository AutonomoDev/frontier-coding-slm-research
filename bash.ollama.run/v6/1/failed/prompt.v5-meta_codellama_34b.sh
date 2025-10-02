# This is a Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names when the user types `ollama run ` and presses the `<TAB>` key.
# The script uses the `bash-completion` framework and must be sourced (e.g., `source my_script.sh`) to enable the functionality.

# Check that the first word is `ollama` and the previous word (`prev`) is exactly `run`.
if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${COMPREPLY[COMP_CWORD-1]}" != "run" ]]; then
  return
fi

# Parse the output of `ollama list` to extract the model names.
models=$(ollama list | tail -n +2 | cut -d' ' -f1)

# Filter the suggestions based on the word the user is currently typing.
filtered_models=()
for model in $models; do
  if [[ "$model" == "$COMP_WORDS[COMP_CWORD]"* ]]; then
    filtered_models+=("$model")
  fi
done

# Output the suggestions to the user.
if [[ "${#filtered_models[@]}" -gt "0" ]]; then
  COMPREPLY=("${filtered_models[@]}")
else
  return
fi

