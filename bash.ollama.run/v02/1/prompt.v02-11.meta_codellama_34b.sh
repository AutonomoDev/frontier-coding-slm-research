```
# Define a completion function for "ollama run <model>"
_ollama_run() {
  # Check if the command is "ollama run" and the user is completing after "run"
  if [[ ${COMP_WORDS[0]} != ollama || ${COMP_WORDS[1]} != run ]]; then
    return
  fi

  # Invoke "ollama list" once and capture its full output into a variable
  local models=$(ollama list)

  # Use the current word being completed (from COMP_WORDS/COMP_CWORD) to filter model names
  local prefix=${COMP_WORDS[COMP_CWORD]}
  local matches=()
  while read -r line; do
    if [[ $line =~ ^$prefix ]]; then
      matches+=("${line#*/}") # Remove path if present, leaving just the basename
    fi
  done <<< "$models"

  # If there are multiple matches, sort them alphabetically before assigning to COMPREPLY
  if (( ${#matches[@]} > 1 )); then
    matches=($(printf '%s\n' "${matches[@]}" | sort))
  fi

  # Populate COMPREPLY correctly using compgen or manual filtering
  COMPREPLY=("${matches[@]}")
}

# Wire the completion function to "ollama"
complete -F _ollama_run ollama
```
Installation:

* Save the script as `~/.bash_completion.d/ollama` (or any other path included in your `$fpath`)
* Source the file or restart your shell to activate completions immediately
* Add the following line to your `.bashrc` (or equivalent) to enable completion for future shell sessions: `[[ -r ~/.bash_completion.d/ollama ]] && source ~/.bash_completion.d/ollama`

