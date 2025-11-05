
# Completion Function for Ollama CLI

This is a bash completion script for the Ollama CLI tool, which provides tab completion for commands and options. The script uses a case statement to handle different completion types based on the subcommand entered.

Here's the complete function:
```bash
_ollama_completions() {
  local cur prev models
  _get_comp_words_by_ref -n : cur prev

  # Handle model name completion for commands that require it
  case "$prev" in
    (show|run|stop|push|cp|rm)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
  esac

  # Handle special flag completion for the "create" command
  case "$prev" in
    (create)
      COMPREPLY=( $( compgen -W '--file -f --quantize -q' -- "$cur" ) )
  esac

  # Handle commands with no argument completion
  case "$prev" in
    (serve|pull|signin|signout|list|ps|help)
      COMPREPLY=( $( compgen -W '${COMP_WORDS[@]:1}' -- "$cur" ) )
  esac
}
```
To use this completion function, you need to register it with the `complete` built-in command. You can do this by running the following command in your terminal:
```bash
complete -F _ollama_completions ollama
```
This will enable tab completion for the Ollama CLI tool whenever you type "ollama" followed by a space.

