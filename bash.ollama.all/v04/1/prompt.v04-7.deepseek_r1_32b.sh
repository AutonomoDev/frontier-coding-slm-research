#!/bin/bash

#Thinking...
#Alright, I need to create a bash completion function for the ollama CLI tool. Let me go through the requirements step by step.
#
#First, the function must be named _ollama_completions and handle tab completions for various commands. The user provided a detailed structure, so I'll follow that closely.
#
#The top-level rule says that if the previous token is 'ollama', it should return all subcommands. So I'll start by checking if we're at the first argument after 'ollama' and list the subcommands accordingly.
#
#Next, there are three groups of commands:
#
#Group 1 includes show, run, stop, push, cp, rm. These require model completion except for stop which uses a different method. For these, I need to fetch models from 'ollama list' or 'ollama ps' for stop. I'll follow the strict steps A-D as provided.
#
#Group 2 has create, pull, run, show with specific flags. Flags come after the model if applicable. So for these commands, after handling the model completion, I need to provide flag completions when the current word starts with '-'.
#
#Group 3 includes commands that don't require any argument completion like serve, start, etc. For these, I'll return empty completions.
#
#I'll structure the function using a case statement based on the subcommand. Each arm will handle its specific logic. 
#
#For each Group 1 command except stop, I'll extract current and previous words, fetch models from ollama list, generate completions, sort them, and trim colons. For stop, I'll do the same but get models from ollama ps.
#
#In Group 2, create uses model completion first then flags. So if the word count is 2, it's model completion; else, handle flags. Similarly, run has both model and flags, so after model, check for flags.
#
#Pull only has flags, so I'll list them when the current word starts with '-'.
#
#I need to ensure that all steps are followed verbatim, no arrays for models, and strictly follow the logic without adding extra error handling beyond what's specified.
#
#Finally, after implementing all cases, I'll register the completion function with 'complete -F _ollama_completions ollama'.
#
#Putting it all together, I'll write each case arm carefully, ensuring that the model completions and flags are handled correctly for each command.
#...done thinking.

function _ollama_completions {
    local cur prev
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Top-level completion if no subcommand is provided
    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
        return
    fi
    
    local subcmd=${words[1]}
    
    case "$subcmd" in
        show|push|cp|rm)
            # Group 1 commands (except stop) using standard model completion
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        run)
            # For 'run', first complete model, then flags
            if [[ ${cword} -eq 2 ]]; then
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            else
                # Flag completion for 'run'
                local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        stop)
            # Special case: model list from ollama ps
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Model completion first, then flags
            if [[ ${cword} -eq 2 ]]; then
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            else
                # Flag completion for 'create'
                local flags="--file -f --quantize -q"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        pull)
            # Flags only
            local flags="--insecure"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # Commands with no argument completion
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
