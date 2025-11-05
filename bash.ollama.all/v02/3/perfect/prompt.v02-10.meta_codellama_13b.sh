#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for the `ollama` command line tool:

# Register the completion function
complete -F _ollama_completions ollama

# Main function to handle completions
_ollama_completions() {
  # Get current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Switch on subcommand
  case "$prev" in
    # Commands requiring <MODEL> completion
    show|run|stop|push|cp|rm)
      # Extract word info
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

      # Generate completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;

    # Command with special flag completion
    create)
      # Generate completions for flags: --file, -f, --quantize, -q
      COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;

    # Commands with no argument completion
    serve|pull|signin|signout|list|ps|help)
      COMPREPLY=()
      ;;
  esac
}

# [[HUMAN COMMENTED-OUT]]
# This script uses a `case` statement to switch on the subcommand and provide different completions based on the command. The `show`, `run`, `stop`, `push`, `cp`, and `rm` commands require completion of `<MODEL>`, which is handled by fetching a list of all models from `ollama list` and generating completions with `compgen`. The `create` command requires special flag completion, which is handled by generating completions for the flags `--file`, `-f`, `--quantize`, and `-q`. Finally, commands such as `serve`, `pull`, `signin`, `signout`, `list`, `ps`, and `help` require no argument completion and are handled with an empty list of completions.