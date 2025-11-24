#Thinking...
#Alright, I need to create a bash completion function for the ollama CLI tool. The user has provided detailed instructions on how the completion should work, so I'll have to follow them closely.
#
#First, I'll start by understanding the structure of the function. It needs to be named _ollama_completions and must handle various subcommands with different completion rules. The function will use a case statement based on the subcommand provided.
#
#Looking at the top-level rule, if the previous token is 'ollama', it should return all possible subcommands. So I'll list them all in that case: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help.
#
#Next, each subcommand has specific rules. For example, commands like show, run, stop, etc., require model completion. I'll need to implement a strict model-completion algorithm for these except for 'stop', which uses 'ollama ps' instead of 'ollama list'.
#
#For the model completion, the steps are fixed: extract current and previous words, fetch models from ollama list or ps depending on the command, generate completions, sort them, and trim. I'll make sure to follow these steps verbatim.
#
#Then there are commands with flags, like create, pull, run, show. These have specific flags that should appear after the model if applicable. For example, 'create' uses model completion first and then shows flags if the current word starts with a '-'.
#
#Commands in Group 3 don't require any arguments, so they return an empty completion set.
#
#I'll structure each case in the switch statement accordingly. For commands requiring models, I'll handle them first, then check for flags if necessary. Commands without model completions will just return nothing or their specific flags.
#
#I need to ensure that all code is within the function and that it doesn't use arrays for model storage, as per constraints. Also, no alternative completion strategies are allowed; everything must follow the specified steps.
#
#Testing each case in my mind: for 'create', if after the command comes a word starting with '-', it should show flags. Otherwise, it completes models. For 'run', similar logic applies but with different flags.
#
#Finally, I'll register the function with complete -F _ollama_completions ollama to enable the tab completion.
#
#I think that covers all the requirements. Now, I'll translate this into bash code, making sure each step is correctly implemented and adheres to the constraints.
#...done thinking.

_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev words cword
    
    local subcommand="${words[1]}"

    case "$subcommand" in
        show|run|stop|push|cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            if [[ "$subcommand" == "stop" ]]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        
        create)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            if [[ "$cur" == -* ]]; then
                local flags="--file -f --quantize -q"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        
        pull)
            local flags="--insecure"
            if [[ "$prev" == "pull" ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        
        run|show)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            if [[ "$prev" == "$subcommand" && "$cur" != -* ]]; then
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ "$prev" == "$subcommand" && "$cur" == -* ]]; then
                local flags
                if [[ "$subcommand" == "run" ]]; then
                    flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                else
                    flags="--license --modefile --parameters --system --template --verbose"
                fi
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
        
        *)
            COMPREPLY=()
            ;;
    esac
    
    return 0
}

complete -F _ollama_completions ollama
