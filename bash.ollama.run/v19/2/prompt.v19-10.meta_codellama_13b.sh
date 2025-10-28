```bash
#!/usr/bin/env bash

# Bash completion script for the `ollama run` command
_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Get current and previous words (colon support)
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Parse models with ollama list, ignoring errors (if command not found)
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  if [ -z "$models" ]; then COMPREPLY=(); return; fi

  # Get completions with compgen, wrapping in array for sorting
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort results and call fix_colon_completions
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

# Register the completion script
complete -F _ollama_completions ollama
```
This script uses the `compgen` builtin to generate completions from a list of possible values. The `-W` flag is used to specify the list of possible values, and the `--` flag tells `compgen` that we're using a fixed set of options rather than allowing any string.

The `sort` command is used to sort the results before passing them to `compgen`, which ensures that they are displayed in alphabetical order. The `__ltrim_colon_completions` function is called after sorting, which trims the prefix from the completions (if there is one).

Finally, the script registers the completion script using the `complete` builtin with the `-F` flag to specify that we're providing a custom completion script.

