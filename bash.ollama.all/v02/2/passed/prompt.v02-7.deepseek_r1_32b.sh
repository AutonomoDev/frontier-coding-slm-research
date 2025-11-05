#!/bin/bash

# Thinking...
# Okay, I need to generate a Bash completion script for the `ollama` command-line tool. Let me start by understanding the requirements.
# 
# First, the user has provided specific commands and how they should be handled. The commands are grouped into three categories: those that require model name completions, a special command with flag completions, and others that don't need argument completions.
# 
# The main function is `_ollama_completions`, which needs to handle all these cases using a case statement. The structure must follow exact steps for fetching model names, especially for the commands in group 1.
# 
# Let me outline each step:
# 
# 1. **Top-Level Completion:** When the user types `ollama` followed by a space and presses tab, the script should list all available subcommands. I need to define an array of these commands: show, run, stop, push, cp, rm, create, serve, pull, signin, signout, list, ps, help.
# 
# 2. **Handling Model Name Completion:** For commands like `show`, `run`, etc., the script needs to fetch model names using `ollama list`. The steps are:
#    - Extract current and previous words.
#    - Check if `ollama` command exists; if not, return empty completions.
#    - Fetch models using `ollama list`, skipping the header with `tail -n +2`.
#    - If no models found, return empty.
#    - Generate completions from these models.
# 
# 3. **Special Case for 'create':** This command has specific flags to complete: --file, -f, --quantize, -q. So when the previous word is 'create', the script should list these flags as possible completions.
# 
# 4. **Other Commands:** These don't need any argument completions, so once they're recognized, no further action is needed beyond what's already handled by Bash.
# 
# I also need to make sure that I follow all constraints: no arrays for models, no extra checks like for `_get_comp_words_by_ref`, and no sorting before `compgen`.
# 
# Putting it all together:
# 
# - The function starts by checking the previous word. If it's 'ollama', list all subcommands.
# - Then, in a case statement, handle each command type:
#   - For commands needing model completion, execute steps A to D as specified.
#   - For 'create', provide flag completions.
#   - Other commands don't need extra handling beyond their recognition.
# 
# Finally, register the function with `complete -F`.
# 
# I think that covers all the requirements. Now, I'll translate this into the bash code step by step, ensuring each part aligns with the user's instructions.
# ...done thinking.

_ollama_completions() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Top-level command completion
    if [[ $prev == "ollama" ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
        return 0
    fi

    case "$prev" in
        # Commands requiring model completion
        show|run|stop|push|cp|rm)
            local models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        # Command with special flags
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
    esac
}

complete -F _ollama_completions ollama
