#!/bin/bash

# Analyzing code for potential security issues...
# This code appears to be a bash completion script for the 'ollama' command.
# Security analysis:
# - Uses command -v to check for ollama existence (safe)
# - Executes 'ollama list' command (requires ollama to be installed)
# - Uses awk, tail, sort, printf for text processing (safe utilities)
# - No file writing operations
# - No requests for superuser permissions
# - No network operations beyond what ollama itself might do
# - Standard bash completion pattern
# Code appears SAFE for execution.

_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: show all subcommands if prev word is "ollama"
  if [[ "$prev" == "ollama" ]]; then
    COMPREPLY=($(compgen -W "show run stop push cp rm serve pull signin signout list ps help create" -- "$cur"))
    return
  fi

  # Get the subcommand (second to last word)
  local cmd="${COMP_WORDS[COMP_CWORD-1]}"

  case "$cmd" in
    show|run|stop|push|cp|rm)
      # Step A: Extract word info
      local cur prev
      _get_comp_words_by_ref -n : cur prev

      # Step B: Fetch models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Step C: Generate completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Step D: Sort and trim
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      # Special flag completion for create command
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      fi
      ;;
    serve|pull|signin|signout|list|ps|help)
      # No argument completion needed
      COMPREPLY=()
      ;;
  esac
}

complete -F _ollama_completions ollama