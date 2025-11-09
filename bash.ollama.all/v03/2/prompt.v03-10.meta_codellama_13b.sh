```bash
#!/bin/bash

_ollama_completions() {
  # Get current word information.
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Switch on the subcommand.
  case "$prev" in
    # Case A: No argument completion for top-level commands.
    1) if [[ $cur == ollama ]]; then
        COMPREPLY=($(compgen -W "serve start pull signin signout list ls ps help" -- "$cur"))
      fi;;

    # Case B: Model name completion for commands requiring <MODEL> completion.
    2) case $prev in
        show|run|stop|push|cp|rm)
          # Fetch models and generate completions.
          if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
          local models
          models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
          [[ -z "$models" ]] && { COMPREPLY=(); return; }
          COMPREPLY=($(compgen -W "$models" -- "$cur"))
          __ltrim_colon_completions "$cur" ;;
        esac;;

    # Case C: Special flag completion for commands with special flags.
    3) case $prev in
        create) COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"));;
        pull) COMPREPLY=($(compgen -W "--insecure" -- "$cur"));;
        run) COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"));;
        show) COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"));;
        esac;;

    # Case D: No argument completion for commands with no arguments.
    4) if [[ $prev == serve|start|pull|signin|signout|list|ls|ps|help ]]; then
          COMPREPLY=($(compgen -W "" -- "$cur"))
        fi;;
  esac
}
```

