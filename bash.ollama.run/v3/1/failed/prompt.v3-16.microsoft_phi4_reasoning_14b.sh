#<think>We are asked: "Write a bash-completion function for `ollama run <model>` that meets all these requirements".
# Requirements:
# 1. Triggering: only when completing model argument after typing `ollama run` but also allow extra whitespace and benign variations; the simplest check is previous word is `run` and command is `ollama`.
# 2. Model list retrieval: Run "ollama list" exactly once, capture full output into a variable. Avoid piping directly to while read loop in subshell that loses array contents. Instead store output in variable then iterate over variable safely.
# 3. Prefix filtering: Use current word being completed (from COMP_WORDS/COMP_CWORD) as the prefix and include only model names that start with that prefix using a straightforward match like `[[ $model == "$cur"* ]]`.
# 4. Sorting: If multiple matching models, sort them alphabetically before assigning to COMPREPLY.
# 5. Populate COMPREPLY correctly: Either build COMPREPLY manually from filtered & sorted results or use compgen -W ... -- "$cur" on a prepared alphabetically sorted list. The result must be valid Bash completion suggestions.
# 6. Graceful failure: If "ollama list" fails or returns empty, return without error and provide no completions.
# 7. No external dependencies: Use only Bash built-ins and GNU coreutils (sort, etc). Assume LINUX support only. Do not assume non-standard helpers are available. If you use _get_comp_words_by_ref, include fallback that manually sets cur and prev from COMP_WORDS/COMP_CWORD if _get_comp_words_by_ref is missing or fails.
# 8. Wiring: Attach the function to "ollama" so that typing "ollama run <Tab>" triggers it.
# 9. Installation instructions: At the end include a minimal example of where to save or source the script and how to activate it immediately (e.g., add a source line to .bashrc and reload).
#
# I need to produce a Bash script that defines bash completion for "ollama run". It has to be dependency-free. It must check if the command is ollama and previous word is run (even if there are extra arguments). Use COMP_WORDS and COMP_CWORD. Then get current prefix using compgen builtins? Wait, instructions: "if _get_comp_words_by_ref is missing then fallback to manual". So we need to check if function _get_comp_words_by_ref exists.
#
# Plan:
# - Define completion function named _ollama_run_complete.
# - Use _get_comp_words_by_ref if available; otherwise fallback to manual extraction of cur and prev.
# - Verify command is "ollama" and that previous token is "run".
# - Run "ollama list" exactly once and capture output in a variable.
# - If command fails or returns empty, return with no completions.
# - Split the output into an array safely, then filter using [[ $model == "$cur"* ]].
# - Sort matches with sort, then use compgen -W "..." -- "$cur" to populate COMPREPLY.
# - Register completion via complete -F _ollama_run_complete ollama.
# - Add installation instructions as comments at the end.
#
# (End of thinking block)</think>

#!/bin/bash
# Bash completion for "ollama run <model>"

_ollama_run_complete() {
  # Use _get_comp_words_by_ref if available; otherwise fall back to manual extraction.
  if ! type _get_comp_words_by_ref &>/dev/null; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  else
    # -n : protects characters like ':' from being treated specially (keeps raw tokens)
    # Request cur and prev variables to be set by the helper.
    _get_comp_words_by_ref -n : cur prev
  fi

  # Ensure the command is 'ollama' and that the word being completed follows 'run'.
  # If previous token is not 'run' then we do not provide completions here.
  if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
    return 0
  fi

  # Run "ollama list" exactly once and capture its entire output.
  # If the command fails, return gracefully with no completions.
  local models
  if ! models=$(ollama list 2>/dev/null); then
    return 0
  fi

  # If no models returned, provide no completions.
  if [[ -z "$models" ]]; then
    return 0
  fi

  # Split the models output into an array. This relies on word-splitting on IFS (default).
  # If model names may contain spaces, additional parsing would be required; assuming
  # model names are single tokens as typical.
  local model_list=($models)

  # Filter models by prefix (current word). Use the simple prefix match requested.
  local filtered=()
  local model
  for model in "${model_list[@]}"; do
    if [[ $model == "$cur"* ]]; then
      filtered+=("$model")
    fi
  done

  # If nothing matches, return without error.
  if [[ ${#filtered[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  # Sort filtered results alphabetically and prepare a word-list for compgen.
  local sorted
  IFS=$'\n' sorted=($(printf "%s\n" "${filtered[@]}" | sort))
  unset IFS

  # Use compgen to generate proper completion candidates and assign to COMPREPLY.
  COMPREPLY=( $(compgen -W "$(printf '%s\n' "${sorted[@]}")" -- "$cur") )
  return 0
}

# Attach the completion function to the 'ollama' command.
complete -F _ollama_run_complete ollama

# Installation:
# Save this file to /etc/bash_completion.d/ollama.sh (system-wide) or to a file in your home directory.
# To activate immediately for the current shell, source it:
#   source /path/to/ollama.sh
# To enable on future shells, add the source line to ~/.bashrc:
#   echo 'source /path/to/ollama.sh' >> ~/.bashrc
# Then reload your shell or run:
#   source ~/.bashrc
