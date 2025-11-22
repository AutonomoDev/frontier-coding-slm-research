_ollama_completions() {
    local cur prev words cword split model_subcmds stop_subcmd run_flags show_flags create_flags pull_flags ollama_ps_models ollama_list_models
    _get_comp_words_by_ref -n : cur prev words cword

    # Extract subcommand (words[1])
    local cmd=${words[1]}

    case "$cmd" in
        # Group 3: Commands with no completion
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;
        # Group 2B and special cases (create, run, show, stop, pull)
        create)
            if [[ "$cur" == -* ]]; then
                create_flags="--file -f --quantize -q"
                COMPREPLY=( $(compgen -W "${create_flags}" -- "$cur") )
                __ltrim_colon_completions "$cur"
                return
            else
                # Step A is covered by _get_comp_words_by_ref above, so Steps B-D can be written directly.
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                printf "%s\n" "${COMPREPLY[@]}" | sort > /dev/null # No action, just to align with D's sort before ltrim.
                __ltrim_colon_completions "$cur"
            fi
            ;;
        run)
            if [[ "$cur" == -* ]]; then
                run_flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=( $(compgen -W "${run_flags}" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                printf "%s\n" "${COMPREPLY[@]}" | sort > /dev/null # Align with D's sort before ltrim.
                __ltrim_colon_completions "$cur"
            fi
            ;;
        show)
            if [[ "$cur" == -* ]]; then
                show_flags="--license --modefile --parameters --system --template --verbose"
                COMPREPLY=( $(compgen -W "${show_flags}" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                printf "%s\n" "${COMPREPLY[@]}" | sort > /dev/null # Align with D's sort before ltrim.
                __ltrim_colon_completions "$cur"
            fi
            ;;
        stop)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
                return
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                printf "%s\n" "${COMPREPLY[@]}" | sort > /dev/null # Align with D's sort before ltrim.
                __ltrim_colon_completions "$cur"
            fi
            ;;
        pull)
            if [[ "$cur" == -* ]]; then
                pull_flags="--insecure"
                COMPREPLY=( $(compgen -W "${pull_flags}" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=()
            fi
            ;;
        # Group 1 (except stop and run/show/create)
        push|cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            printf "%s\n" "${COMPREPLY[@]}" | sort > /dev/null # Align with D's sort before ltrim.
            __ltrim_colon_completions "$cur"
            ;;
        *)
            # Top-level completion: list subcommands
            local commands="show run stop push cp rm create pull serve start signin signout list ls ps help"
            COMPREPLY=( $(compgen -W "${commands}" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
    esac
}

complete -F _ollama_completions ollama

