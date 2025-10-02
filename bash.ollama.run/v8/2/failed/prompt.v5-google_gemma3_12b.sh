# Bash completion script for ollama run command
# Handles model names containing colons.
# Compatible with bash-completion framework v2.

# Function to find the index of "run" in the COMP_WORDS array
_ollama_run_find_run_index() {
  local words=($(COMP_WORDS))
  local run_index=-1
  for ((i=0; i<${#words[@]}; i++)); do
    if [[ "${words[i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done
  echo "$run_index"
}

# Main completion function
_ollama_run_completion() {
  local old_wb="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon, save old value
  local run_index
  run_index=($_ollama_run_find_run_index)

  # Trigger completion only when COMP_CWORD is the character after "run"
  if [[ "$COMP_CWORD" -eq $((run_index + 1)) ]]; then
    # Get the current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || { cur="${COMP_WORDS[COMP_CWORD]}" ; prev="${COMP_WORDS[COMP_CWORD-1]}"}}"

    # Get the list of models from ollama list
    # Use awk for robust parsing
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Generate completion candidates
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Clear COMPREPLY if no completions are found
    if [ ${#COMPREPLY[@]} -eq 0 ]; then
      COMPREPLY=()
    fi
  else
    COMPREPLY=() # Clear if not at the right position
  fi

  COMP_WORDBREAKS="$old_wb"  # ALWAYS restore before ANY return/exit
}

# Register the completion function
complete -F _ollama_run_completion ollama

# Example usage for testing (remove in production)
# ollama_run_completion

# Explanation:

# 1. `_ollama_run_find_run_index()`:  This function dynamically determines the position of "run" within the command line. This avoids hardcoded indices which would break if the command changes.

# 2. `_ollama_run_completion()`:  This is the main completion function.
#   - It saves and restores `COMP_WORDBREAKS` to handle colons correctly.
#   - It finds the position of "run".
#   - It checks if `COMP_CWORD` is the character after "run" to trigger completion.
#   - It uses `ollama list` and `awk` to reliably parse model names.  This avoids issues with variable whitespace in the output of `ollama list`.
#   - `compgen -W` generates completion candidates. This is the preferred method as it handles special characters correctly.
#   - Clears `COMPREPLY` if no completions match, preventing unexpected behavior.
#   - Sets `COMPREPLY=()` if not at the expected position to disable completion at wrong places.

# 3. `complete -F`: Registers the completion function for the `ollama` command.  The `-F` option tells `complete` to use a function for completion, and this function will be called when the user presses Tab after `ollama`.  The `-o default` option is deliberately omitted, as we want to restrict completions to specifically `ollama run` completions.

# 4. Comments: The script is heavily commented to explain each step and the rationale behind the choices.  This makes it easier to understand and maintain.

