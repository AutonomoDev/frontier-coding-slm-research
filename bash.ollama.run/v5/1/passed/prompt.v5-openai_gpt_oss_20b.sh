#Thinking...
#We need to write a Bash completion script for `ollama run` that suggests model names only. We must parse output of `ollama list`. The requirement prohibits awk. So we need to use `cut` or read line by line and split. We can use `read` to parse the first column. But the first column may contain spaces? Actually names are single words with colon. There may be spaces after name due to alignment. We can read using `cut -d' ' -f1` but there might be multiple spaces and we don't want empty fields. We can use `awk` but prohibited. So we can use `cut -d' ' -f1` but it will treat multiple spaces as delimiter and produce empty fields if consecutive spaces. Instead we can use `read` with IFS to split. Let's do:
#
#while IFS= read -r line; do
#  if [[ $line == NAME* ]]; then continue; fi
#  model="${line%%[[:space:]]*}" # take until first whitespace
#  models+=("$model")
#done < <(ollama list)
#
#We need to ensure we skip header. Use `[[ $line == NAME* ]]` or `[[ $line == NAME* ]]` or start with "NAME". So we can use: [[ $line == NAME* ]]. That should skip header.
#
#But we also need to ensure no duplicates. Since output may have unique names. We can sort -u later.
#
#Then we need to filter suggestions based on cur.
#
#We'll set cur=${COMP_WORDS[COMP_CWORD]}. prev=${COMP_WORDS[COMP_CWORD-1]}.
#
#We must check that the second word is 'run'. In COMP_WORDS array, index 0 is command name 'ollama', index 1 is subcommand 'run', index 2 is the first argument being completed. So we check [[ ${COMP_WORDS[1]} == run ]]. If not, return 0.
#
#We must avoid filename fallback: In bash completion, by default, if COMPREPLY is empty, it falls back to file names? Actually Bash default completion fallback? In bash-completion, if you set `COMPREPLY=()` and you want no fallback, you need to set `return 0`? Let's recall: In bash-completion, if completion function returns 0 and COMPREPLY is empty, it may fallback to filename completion unless the script explicitly sets `return 1`. Actually typical pattern: The function returns 0 to indicate completion was handled; if no completions, return 0 and leave COMPREPLY empty. The default fallback might still occur? But requirement says must not fallback to filenames. So we should explicitly set `COMPREPLY=()` and return 0; this should prevent fallback. In many scripts, they call `return 0`. But if we want to avoid fallback, maybe we set `COMPREPLY=()` and `return 0`. Many completion functions do that. I think that's fine.
#
#Also requirement 8: If we use `_get_comp_words_by_ref`, include fallback if missing. But we decided not to use it. So we skip that.
#
#Also we must be compatible with bash-completion v2. They may define `COMPREPLY` and `COMPREPLY=(...)`. Good.
#
#We need to implement function _ollama_completions for run. Register with complete -F.
#
#Script will be:
#
## Bash completion for ollama run
#
#_ollama_run_completion() {
#  local cur prev words cword
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"
#  words=("${COMP_WORDS[@]}")
#  cword=$COMP_CWORD
#
#  # Only trigger when second word is 'run'
#  if [[ ${words[1]} != run ]]; then
#    return 0
#  fi
#
#  # Get list of models
#  local models=()
#  # Use process substitution to capture output
#  while IFS= read -r line; do
#    # Skip header
#    if [[ $line == NAME* ]]; then
#      continue
#    fi
#    # Skip empty lines
#    [[ -z $line ]] && continue
#    # Extract first word (up to first whitespace)
#    local model="${line%%[[:space:]]*}"
#    # Skip if empty
#    [[ -z $model ]] && continue
#    models+=("$model")
#  done < <(ollama list)
#
#  # Remove duplicates (sort -u)
#  IFS=$'\n' sorted_models=($(printf '%s\n' "${models[@]}" | sort -u))
#  unset IFS
#
#  # Filter by current word
#  COMPREPLY=()
#  for m in "${sorted_models[@]}"; do
#    if [[ $m == $cur* ]]; then
#      COMPREPLY+=("$m")
#    fi
#  done
#
#  return 0
#}
#
## Register completion
#complete -F _ollama_run_completion ollama
#
#Add comment lines at top. Ensure no shebang.
#
#We also need to handle possible missing 'ollama' command? If not present, function still returns. That's fine.
#
#Edge: If ollama list fails (non-zero exit), loop will run with no output, models empty, COMPREPLY empty. Good.
#
#We also need to ensure no duplicate suggestions: we sorted unique.
#
#We must not fallback to filenames: return 0 with COMPREPLY empty.
#
#Make sure all lines start with # unless they are code lines. So code lines do not start with #. Good.
#
#Let's write final script with comments.
#
#We'll put #!/usr/bin/env bash? The requirement says script is sourced, so no shebang. But we can include but not necessary. It says "All non-code lines start with #." So we can put comments at top, but code lines start normally.
#
#Let's produce final script.
#...done thinking.

# Bash completion for the `ollama run` command
#
# This script provides autocompletion of local model names when the user types:
#   ollama run <TAB>
#
# It parses the output of `ollama list`, extracts only the model names,
# and suggests them based on the word currently being typed.
# No filename fallback is performed.
# Duplicate model names are removed from the suggestion list.

_ollama_run_completion() {
  # Current word being completed
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Only trigger after the `run` subcommand
  if [[ ${COMP_WORDS[1]} != run ]]; then
    return 0
  fi

  # Retrieve the list of local models
  local models=()
  while IFS= read -r line; do
    # Skip the header line that starts with "NAME"
    if [[ $line == NAME* ]]; then
      continue
    fi
    # Skip empty lines
    [[ -z $line ]] && continue
    # Extract the first word (model name) up to the first whitespace
    local model="${line%%[[:space:]]*}"
    [[ -z $model ]] && continue
    models+=("$model")
  done < <(ollama list)

  # Remove duplicates by sorting uniquely
  IFS=$'\n' local sorted_models=($(printf '%s\n' "${models[@]}" | sort -u))
  unset IFS

  # Filter suggestions based on the current word
  COMPREPLY=()
  for m in "${sorted_models[@]}"; do
    if [[ $m == $cur* ]]; then
      COMPREPLY+=("$m")
    fi
  done

  # Return 0 to indicate completion was handled; no filename fallback
  return 0
}

# Register the completion function for the `ollama` command
complete -F _ollama_run_completion ollama

# End of script
