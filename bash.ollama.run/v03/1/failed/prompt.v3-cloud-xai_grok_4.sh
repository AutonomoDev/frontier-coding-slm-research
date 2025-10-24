# Bash completion function for `ollama run <model>`
_ollama_completion() {
  # Initialize variables
  local cur prev
  # Fallback to manual word extraction if _get_comp_words_by_ref is unavailable
  if ! type _get_comp_words_by_ref &>/dev/null; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  else
    _get_comp_words_by_ref cur prev
  fi

  # Only proceed if command is `ollama` and previous word is `run`
  [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]] && return 0

  # Capture `ollama list` output into variable, skip header
  local output
  output=$(ollama list 2>/dev/null | tail -n +2)
  [[ -z "$output" ]] && return 0  # Exit if empty or command fails

  # Array to store model names
  local -a models=()
  # Read output line by line, extract first column (model name)
  while IFS=$'\t' read -r model _; do
    [[ -n "$model" ]] && models+=("$model")
  done <<<"$output"

  # Filter models by prefix and sort
  local -a filtered=()
  for model in "${models[@]}"; do
    [[ "$model" == "$cur"* ]] && filtered+=("$model")
  done
  # Sort filtered array alphabetically
  mapfile -t filtered < <(printf '%s\n' "${filtered[@]}" | sort)

  # Populate COMPREPLY with filtered, sorted models
  COMPREPLY=($(compgen -W "${filtered[*]}" -- "$cur"))
}

# Register completion function for `ollama`
complete -F _ollama_completion ollama

# Installation instructions:
# 1. Save this script as ~/.ollama_completion.sh
# 2. Add to ~/.bashrc: source ~/.ollama_completion.sh
# 3. Activate immediately: source ~/.ollama_completion.sh
