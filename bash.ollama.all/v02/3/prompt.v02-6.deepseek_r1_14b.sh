#!/bin/bash

# Bash completion script for 'ollama' command line tool

#Thinking...
#Okay, I need to create a Bash completion script for the `ollama` command-line tool. The goal is to generate a single function called `_ollama_completions` that provides tab completion for various commands and their arguments.
#
#First, let me understand the structure of the problem. The user has specified different groups of commands with varying completion behaviors. I need to handle each group appropriately within the function.
#
#The main function will be named `_ollama_completions`. It should use a `case` statement based on the subcommand to determine what kind of completions to provide.
#
#Starting with top-level completion: if the previous word is `ollama`, it should list all the subcommands. So, I'll check if the current word is just 'ollama' and then offer all possible commands as completions.
#
#Next, for the commands that require model names (like `show`, `run`, etc.), there's a specific process to follow. The user has laid out exact steps for this:
#
#1. Extract the current and previous words using `_get_comp_words_by_ref`.
#2. Check if `ollama` is installed; if not, return empty.
#3. Fetch model names by running `ollama list`, parsing the output, and extracting the first column.
#4. If no models are found, return empty.
#5. Generate completions for the current word using `compgen -W`.
#6. Sort the results and trim any colons.
#
#I need to ensure I follow these steps precisely without adding any extra logic or checks.
#
#For the `create` command, it has specific flags that need completion: `--file`, `-f`, `--quantize`, `-q`. So in the case where the subcommand is `create`, I'll list these options as possible completions.
#
#The other commands like `serve`, `pull`, etc., don't require any arguments, so their completion will simply be an empty string to indicate no further completions are needed.
#
#I must remember not to use arrays for storing models and avoid checking for certain functions or variables. Also, the models shouldn't be sorted before passing to `compgen`.
#
#Putting it all together, I'll structure the function with a `case` statement for each command type, applying the specific logic as required. Finally, I'll register the completion function using `complete -F _ollama_completions ollama`.
#...done thinking.

function _ollama_completions {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Top-level command completion
    if [[ "$prev" == "ollama" ]]; then
        COMPREPLY=($(compgen -W "serve pull signin signout list ps help create show run stop push cp rm" -- "$cur"))
        return
    fi

    case $prev in
        # Commands requiring model name completion
        show|run|stop|push|cp|rm)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && {
                COMPREPLY=()
                return
            }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        # Command with flag completion
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
        # Commands with no argument completion
        serve|pull|signin|signout|list|ps|help)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
