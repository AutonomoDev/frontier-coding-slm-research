#Thinking...
#Okay, I need to generate a Bash completion script for the `ollama` command line tool. The user has provided specific groups of commands and their completion behaviors. Let me break down the requirements step by step.
#
#First, the main function must be named `_ollama_completions`. It should handle different subcommands and provide appropriate completions based on the context. I'll use a `case` statement to switch on the subcommand.
#
#The top-level completion is when the previous word is `ollama`, so I need to list all available subcommands. I'll extract these by running `ollama help` and parsing the output. The commands are listed in the usage section, so I can grep for lines starting with a space and extract the command names.
#
#Next, for commands requiring `<MODEL>` completion (Group 1), I must follow the exact steps provided. This involves extracting the current and previous words, fetching the model list using `ollama list`, handling cases where the command isn't found or there are no models, generating completions with `compgen`, sorting them, and trimming colons.
#
#For commands with special flags (Group 2), I need to handle flag completion after the model. For example, `create` has specific flags that should be offered once a model name is provided. The logic here is to check if the current word starts with '-' and then provide the relevant flags as completions.
#
#The commands in Group 3 don't require any argument completion beyond their subcommand, so they don't need special handling in the case statement.
#
#For the `stop` command (Group 4), I need to fetch running models using `ollama ps`. The output includes model names and IDs, but I only need the model names. I'll extract the first column after the header and use those for completion.
#
#I also need to make sure not to use arrays for storing models, avoid fallback logic, and ensure that the code doesn't sort models before passing to `compgen` as per constraints.
#
#Putting it all together, I'll structure the function with a case statement for each subcommand. For each command, I'll handle the completion logic based on its group. I'll include comments for clarity but keep them brief.
#
#Finally, I'll register the completion function at the end using `complete -F _ollama_completions ollama` to ensure it's applied.
#...done thinking.

_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Handle top-level command completion
    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$(ollama help | grep '  [a-zA-Z]' | awk '{print $1}' | tr '\n' ' ')" -- "$cur"))
        return
    fi

    case "${prev}" in
        # Group 1: Commands requiring <MODEL> completion
        show|run|stop|push|cp|rm)
            # Step A: Extract word info (already done above)
            # Step B: Fetch models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            # Step C: Generate completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            # Step D: Sort and trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;
        
        # Group 2: Commands with special flag completion
        create)
            if [[ "$cur" == -* ]]; then
                local flags="--file -f --quantize -q"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            return
            ;;
        pull)
            if [[ "$cur" == -* ]]; then
                local flags="--insecure"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            return
            ;;
        run|show)
            # Note: 'run' and 'show' are already handled in Group 1, but flags are handled here
            if [[ "$cur" == -* ]]; then
                case "${prev}" in
                    run)
                        local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                        ;;
                    show)
                        local flags="--license --modefile --parameters --system --template --verbose"
                        ;;
                esac
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            return
            ;;

        # Group 3: Commands with no argument completion
        serve|start|pull|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;
        
        stop)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local running_models
            running_models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$running_models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$running_models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            return
            ;;
    esac

    # Fallback if nothing matches
    COMPREPLY=()
}
complete -F _ollama_completions ollama

