# Thinking...
# Alright, I need to generate a Bash completion script for the `ollama` command line tool. The user has provided specific groups of commands and their respective completions. Let me break down the requirements step by step.
# 
# First, I should create a function named `_ollama_completions`. This function will handle all the completion logic. The structure must use a case statement based on the subcommand.
# 
# The main points to cover are:
# 
# 1. **Top-level completion**: When the user types `ollama` followed by a space, the script should list all available subcommands. I'll get these by running `ollama help` and processing the output to extract command names.
# 
# 2. **Model name completion for specific commands**: Commands like `show`, `run`, etc., require model names. The user specified exact steps: using `_get_comp_words_by_ref` to get current and previous words, fetching models with `ollama list`, handling errors, generating completions, sorting, and trimming.
# 
# 3. **Special flags for certain commands**: For example, `create` has specific flags that should be completed after the model name. I'll need to check if a flag is expected next by looking at the previous word.
# 
# 4. **No argument completion for some commands**: Commands like `serve`, `start`, etc., don't take arguments, so no completions are needed beyond the command itself.
# 
# 5. **Stop command specifics**: For `stop`, the models should be fetched from `ollama ps` instead of `list`. I'll need to parse that output differently.
# 
# I must ensure that for each case in the subcommand, the correct completion logic is applied. Also, avoid using arrays for models and follow the exact steps provided for model fetching.
# 
# Let me structure the function:
# 
# - Start by checking if the previous word is `ollama` for top-level completions.
# - Use a case statement to handle each subcommand.
# - For commands requiring models, implement the four-step process as specified.
# - Handle flags after model names where necessary.
# - Ensure that for commands without arguments, no further completion is done.
# 
# I'll also need to register the completion function at the end with `complete -F`.
# 
# Potential issues to watch out for:
# 
# - Correctly parsing the output of `ollama list` and `ps` to extract model names without errors.
# - Handling cases where the model list might be empty, ensuring no completions are provided in such cases.
# - Properly handling flags after the model name, checking if a flag is expected next.
# 
# I'll proceed step by step, implementing each part as per the user's instructions, making sure not to deviate from the specified logic and constraints.
# ...done thinking.

function _ollama_completions {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Handle top-level command completion
    if [[ $prev == "ollama" ]]; then
        local commands=$(ollama help | grep -oP '\b\w+\b' | grep -vE '^(help|completion)$')
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi

    case "$prev" in
        # Commands requiring model name completion
        show|run|stop|push|cp|rm)
            local models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            if [[ $prev == "stop" ]]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        
        # Commands with special flags
        create)
            local flags="--file -f --quantize -q"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            fi
            ;;
        run)
            local run_flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$run_flags" -- "$cur"))
            fi
            ;;
        show)
            local show_flags="--license --modefile --parameters --system --template --verbose"
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "$show_flags" -- "$cur"))
            fi
            ;;
        
        # Commands with no argument completion
        serve|start|pull|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
