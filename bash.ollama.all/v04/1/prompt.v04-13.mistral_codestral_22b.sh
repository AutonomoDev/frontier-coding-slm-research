 _ollama_completions() {
      local cur prev words cword
      _get_comp_words_by_ref -n : cur prev words cword

      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

      case "${words[1]}" in
          # Subcommands that require <MODEL> completion (Group 1)
          show | run | push | cp | rm )
              _ollama_complete_models "$cur"
              ;;
          stop )
              local models
              models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
              COMPREPLY=($(compgen -W "$models" -- "$cur"))
              COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
              __ltrim_colon_completions "$cur"
              ;;
          # Subcommands with flags (Group 2)
          create )
              if [[ ${words[cword-1]} == -* ]]; then
                  COMPREPLY=($(compgen -W "--file -f --quantize -q " -- "$cur"))
              else
                  _ollama_complete_models "$cur"
              fi
              ;;
          pull )
              COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
              ;;
          run )
              if [[ ${words[cword-1]} == -* ]]; then
                  COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
              else
                  _ollama_complete_models "$cur"
              fi
              ;;
          show )
              if [[ ${words[cword-1]} == -* ]]; then
                  COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
              else
                  _ollama_complete_models "$cur"
              fi
              ;;
          # Subcommands with NO argument completion (Group 3)
          serve | start | signin | signout | list | ls | ps | help )
              COMPREPLY=()
              ;;
          * )
              if [[ $cword -eq 1 ]]; then
                  # If the previous token is `ollama`, return subcommands list.
                  COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
              fi
              ;;
      esac
  }

  _ollama_complete_models() {
      local cur models
      cur=$1
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
  }

  complete -F _ollama_completions ollama

