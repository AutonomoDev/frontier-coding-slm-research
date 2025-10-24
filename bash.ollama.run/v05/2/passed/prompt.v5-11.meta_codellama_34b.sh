# This is a Bash completion script for the `ollama run` command.
# The script provides autocompletion suggestions for model names when a user types `ollama run ` and presses `<TAB>`.

_ollama_run () {
    # Check if the second word (`${COMP_WORDS[1]}`) is exactly `run`, to ensure that the completion logic only activates for this subcommand.
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
      return 0
    fi

    # Get the list of available local models by running the command `ollama list`.
    # Store the output in a variable called `$list`.
    list=$(ollama list)

    # Extract only the model names from the first column (e.g., `llama3:latest`, `codellama:7b-instruct`).
    # Use standard and reliable tools like `awk '{print $1}'` or `cut` for this parsing.
    models=$(echo "$list" | awk 'NR>1{print $1}')

    # Check if the user is currently typing a model name, and filter the suggestions based on it.
    if [[ "${COMP_WORDS[2]}" != "" ]]; then
      # If the user is typing a model name, only suggest models that match what they've typed so far.
      # Use Bash parameter expansion to remove any characters after the last colon in the string.
      cur=${COMP_WORDS[2]##*:}
      # Loop through each model and check if it starts with the current word.
      for model in $models; do
        # If a model starts with the current word, add it to the list of suggestions.
        if [[ "$model" == "$cur"* ]]; then
          COMPREPLY+=("$model")
        fi
      done
    else
      # If the user is not typing a model name, suggest all available models.
      COMPREPLY=($models)
    fi

    # Check if there are any duplicate entries in the completion suggestions.
    if [[ "${#COMPREPLY[@]}" -gt "1" ]]; then
      # If there are duplicates, remove them using an associative array (a Bash 4 feature).
      declare -A suggestions
      for suggestion in "${COMPREPLY[@]}"; do
        ((suggestions[$suggestion])) || COMPREPLY+=("$suggestion")
      done
    fi

    # Finally, return the list of completion suggestions.
    return 0

}
complete -F _ollama_run ollama
