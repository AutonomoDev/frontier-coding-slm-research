# Bash completion script for ollama command line tool

# [[HUMAN COMMENTED-OUT]]
#Thinking...
#Okay, I need to generate a Bash completion script for the `ollama` command-line tool. The user has provided specific requirements, so I'll have to make sure I follow them closely.
#
#First, the task is to create a single function named `_ollama_completions`. This function will handle tab completion for various commands and their arguments. Let me break down the problem step by step.
#
#The user grouped the commands into four categories. The first group includes commands that require `<MODEL>` completion: `show`, `run`, `stop`, `push`, `cp`, `rm`. For these, I need to fetch available models using `ollama list` and provide those as completions. 
#
#Next, there are commands with special flags, like `create` which has flags such as `--file`, `-f`, etc. These flags must be completed after the model name. So, for example, when the user types `ollama create -f`, the script should recognize that `-f` is a valid flag.
#
#The third group consists of commands with no argument completion: `serve`, `start`, `pull`, `signin`, `signout`, `list`, `ls`, `ps`, `help`. For these, I don't need to provide any model or flag completions beyond the command itself.
#
#For the `stop` command, it's a bit different because it uses the output from `ollama ps` to get model names. So when completing `stop`, the script should run `ollama ps` and extract the model names (first column) from that output.
#
#The functional requirements specify using a `case` statement within the function. The main steps involve checking if the previous word is `ollama` and providing subcommand completions, then handling each command's specific completion logic.
#
#I also need to ensure that for commands requiring model completion, I follow the exact four-step process: extract word info, fetch models, generate completions, sort and trim. Importantly, I shouldn't use arrays for models; they should be a string with spaces separating each model name.
#
#For flags after model names in commands like `create`, I'll need to check if the current word is a flag and then provide the relevant options. For example, if the command is `create` and the previous word is `-f`, it's a valid option.
#
#I should also handle cases where the `ollama` command isn't found by checking with `command -v` and returning early to avoid errors.
#
#Finally, after defining all the case statements, I need to register the completion function using `complete -F _ollama_completions ollama`.
#
#Let me structure the code step by step. Start with the function definition, then handle top-level completion when the previous word is `ollama`. Then, for each command in the first group, apply the model completion steps. For commands with flags, check if the current word starts with a flag and provide completions accordingly. Commands without arguments will just have their subcommand names as completions.
#
#I need to make sure that all edge cases are handled, like when `ollama list` returns nothing or when there's no previous command. Also, ensuring that sorting is done correctly and that the output is trimmed if necessary.
#
#Testing each part in my mind: for `show`, it should complete model names; for `create`, after a model name, it should offer flags. For `stop`, it fetches models from `ps`. Commands like `serve` just have their own names as completions.
#
#I think I've covered all the requirements and constraints. Now, putting this into code with appropriate comments explaining each part.
#...done thinking.

function _ollama_completions {
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # If no previous word, offer all subcommands
    if [[ "$prev" == "ollama" ]]; then
        COMPREPLY=($(compgen -W "serve start pull signin signout list ls ps help show run stop push cp rm create" -- "$cur"))
        __ltrim_colon_completions "$cur"
        return
    fi
    
    # Determine the subcommand and handle completions accordingly
    case $prev in
        serve|start|pull|signin|signout|list|ls|ps|help)
            COMPREPLY=($(compgen -W "$prev" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        show|run|stop|push|cp|rm)
            # Step A: Extract Word Info
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            # Step B: Fetch Models
            if ! command -v ollama &>/dev/null; then 
                COMPREPLY=()
                return
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Step C: Generate Completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Step D: Sort and Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Handle flags after model name
            if [[ "$cur" == -*f ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            else
                # If no flag, complete with model names first
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        pull|run|show)
            # Handle flags after model name for commands with special flags
            if [[ "$cur" == --* ]]; then
                case $prev in
                    run) COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur")) ;;
                    show) COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur")) ;;
                    pull) COMPREPLY=($(compgen -W "--insecure" -- "$cur")) ;;
                esac
            else
                # If no flag, complete with model names first
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        stop)
            # Get running models from ps
            local models
            models=$(ollama ps 2>/dev/null | awk '{print $1}')
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        *)
            # If command not recognized, offer no completions
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
