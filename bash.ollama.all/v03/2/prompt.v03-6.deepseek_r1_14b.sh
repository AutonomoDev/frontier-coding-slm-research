Thinking...
Alright, I need to generate a Bash completion script for the `ollama` command. The user provided specific requirements, so I'll go through them step by step.

First, the main function has to be named `_ollama_completions`. It should use a case statement based on the subcommand. So I'll structure it with a big case loop inside the function.

The top-level completion is when the previous word is `ollama`, so I need to list all subcommands. I'll make sure that if the current word is empty, it shows all possible commands.

For the commands requiring `<MODEL>` completion (like show, run, etc.), I have to follow precise steps. I'll extract the current and previous words using `_get_comp_words_by_ref`. Then, check if `ollama` exists; if not, return nothing. Next, fetch the models by running `ollama list`, parsing the output to get model names. If there are no models, return. Otherwise, generate completions with `compgen -W`, sort them, and trim any colons.

I must avoid using arrays for models, so I'll keep it as a string. Also, don't add fallbacks or check for certain functions, so I won't include those checks.

For commands with special flags (like create, pull), after handling model completion if needed, I'll process the flags. Each command's flags are listed, and I'll use `compgen -A` to generate completions based on whether it's a flag or option.

Commands without argument completion (serve, start, etc.) just return nothing since they don't need completions.

I also need to handle the stop command by running `ollama ps` to get model names. So in the case where the subcommand is stop, I'll fetch the models from ps instead of list.

Finally, after writing all cases, I'll register the function with `complete -F _ollama_completions ollama` at the end.

I have to make sure the code is clean and follows all constraints. Testing each part logically should cover all scenarios.
...done thinking.

```bash
function _ollama_completions {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    if [[ "$cur" == "ollama" ]]; then
        # Top-level completion: list all subcommands
        COMPREPLY=($(compgen -W "$(ollama --help 2>/dev/null | grep '^\S' | sed 's/[^a-zA-Z0-9_]\+/ /g' | awk '{print $1}' | sort)" -- "$cur"))
        return
    fi

    case $(basename "$prev") in
        show|run|stop|push|cp|rm)
            # Model completion for commands requiring <MODEL>
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Model completion followed by flags
            if [[ "$cur" != */* ]]; then
                # Handle model completion first
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                return
            fi
            # Flags for create command
            COMPREPLY=($(compgen -A 'create: --file, -f, --quantize, -q' -- "$cur"))
            ;;
        pull)
            if [[ "$cur" != */* ]]; then
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                return
            fi
            COMPREPLY=($(compgen -A 'pull: --insecure' -- "$cur"))
            ;;
        run)
            if [[ "$cur" != */* ]]; then
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                return
            fi
            COMPREPLY=($(compgen -A 'run: --format, --hidethinking, --insecure, --keepalive, --nowordwrap, --think, --verbose' -- "$cur"))
            ;;
        stop)
            # Get running models from ps command
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        default)
            # Handle other commands with no completion
            COMPREPLY=()
            ;;
    esac

    return 0
}

# Register the completion function
complete -F _ollama_completions ollama
```

