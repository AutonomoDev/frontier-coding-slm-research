#Thinking...
#Okay, I need to create a bash completion function for the ollama CLI called _ollama_completions. The function must handle various subcommands and their argument completions as specified.
#
#First, I'll start by outlining the structure of the function based on the requirements. The function needs to begin by calling _get_comp_words_by_ref to get the current and previous words. Then, it extracts the subcommand from words[1].
#
#Next, I'll handle each group of commands separately. For Group 1 commands (show, run, stop, push, cp, rm), except for 'stop', model completion is needed using Steps A-D as described. For 'stop', I need to fetch models from ollama ps instead of ollama list.
#
#For Group 2 commands (create, pull, run, show), flags are involved. Notably, create uses model completion first, then handles flags. The other commands in this group have specific flags that should be completed when the current word starts with a '-'.
#
#Group 3 commands (serve, start, signin, etc.) don't require any argument completions, so they return an empty array.
#
#I also need to ensure that for create, after handling model completion, if there's no match, it falls back to flag completion. Similarly, run and show should handle flags when the current word starts with '-'.
#
#Additionally, the top-level completion must list all subcommands when the previous token is 'ollama'.
#
#I'll structure the function using a case statement for each possible subcommand, ensuring that each arm follows the exact logic without any fallback paths beyond what's specified. I'll make sure to return immediately after producing completions to avoid unnecessary processing.
#
#Finally, I'll register the completion function with complete -F _ollama_completions ollama.
#...done thinking.

function _ollama_completions {
    _get_comp_words_by_ref -n : cur prev words cword
    local subcommand=${words[1]}

    case $subcommand in
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return ;;
        
        '')
            COMPREPLY=(show run stop push cp rm create pull serve start signin signout list ls ps help)
            __ltrim_colon_completions "$cur"
            return ;;
    
        show|run|push|cp|rm)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return ;;
        
        stop)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return ;;
        
        create)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if [[ $cur == -* ]]; then
                COMPREPLY=(--file -f --quantize -q)
                __ltrim_colon_completions "$cur"
                return
            fi
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return ;;
        
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=(--insecure)
                __ltrim_colon_completions "$cur"
                return
            fi
            COMPREPLY=()
            return ;;
        
        run)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if [[ $cur == -* ]]; then
                COMPREPLY=(--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose)
                __ltrim_colon_completions "$cur"
                return
            fi
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return ;;
        
        show)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if [[ $cur == -* ]]; then
                COMPREPLY=(--license --modefile --parameters --system --template --verbose)
                __ltrim_colon_completions "$cur"
                return
            fi
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return ;;
    esac
}

complete -F _ollama_completions ollama
