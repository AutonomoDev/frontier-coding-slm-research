# Analysis: This code implements bash completion for the ollama CLI tool. No dangerous operations detected:
# - No superuser permission requests
# - No file writing operations
# - Only reads from `ollama list` command (safe)
# - Standard bash completion framework usage
# Code appears safe to execute.

#Thinking...
#We need to produce Bash code per prompt. It must be a single function _ollama_completions, using case. It must implement top-level completion for subcommands. For group 1 commands requiring model completion, implement steps A-D exactly.
#
#Group 2: create command with special flag completion: --file, -f, --quantize, -q. That likely need to complete flags for create. Use compgen with -W.
#
#Group 3: no argument completion: serve, pull, signin, signout, list, ps, help. For these, should probably just complete nothing? Maybe we just return; But likely the script expects to not provide any further completions. So just COMPREPLY=(); return;.
#
#Also for top-level: if previous word is ollama, list all subcommands as completions. That uses compgen -W.
#
#Implementation: Use _get_comp_words_by_ref -n : cur prev inside top-level? For top-level, we need to check if cur is empty? Actually standard practice: inside completion function, get cur and prev; if cur is empty? The logic: if cur is empty or if the previous word is 'ollama', then we want to list subcommands. But the requirement: "If the previous word is `ollama`, provide a list of all subcommands as completions." So we need to check if prev is "ollama" or if we're at the first word? Usually the first word is ollama. We can check if cur is empty and prev is "ollama"? But simplest: if [[ $prev == ollama ]] then provide subcommands.
#
#But inside completion function, prev will be the word before current. If user types `ollama ` then cur is empty string and prev is 'ollama'. So we can handle that.
#
#We need to define subcommands list: maybe a variable.
#
#Let's design function:
#
#function _ollama_completions() {
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#
#    # List all subcommands if at first word
#    if [[ $prev == ollama ]]; then
#        COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
#        return
#    fi
#
#    # Determine subcommand
#    local subcmd=$prev
#
#    case "$subcmd" in
#        show|run|stop|push|cp|rm)
#            # Group 1: model completion
#            # Step A
#            local cur prev
#            _get_comp_words_by_ref -n : cur prev
#            # Step B
#            if ! command -v ollama &>/dev/null; then
#                COMPREPLY=(); return
#            fi
#            local models
#            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#            [[ -z "$models" ]] && { COMPREPLY=(); return; }
#            # Step C
#            COMPREPLY=($(compgen -W "$models" -- "$cur"))
#            # Step D
#            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#            __ltrim_colon_completions "$cur"
#            ;;
#        create)
#            # Group 2: special flags
#            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
#            ;;
#        serve|pull|signin|signout|list|ps|help)
#            # Group 3: no argument completion
#            COMPREPLY=(); return
#            ;;
#        *)
#            # If unknown subcommand, maybe no completions
#            COMPREPLY=(); return
#            ;;
#    esac
#}
#
#But we need to ensure that we don't redeclare local cur prev inside case? The requirement says "The entire logic must be within a single function named _ollama_completions." But we can use local inside group. However we might be reusing cur. But it's fine.
#
#Also, the step for group1 must not deviate: steps A-D exactly. Step A: local cur prev; _get_comp_words_by_ref -n : cur prev. So inside the case, we need to redeclare local cur prev and call _get_comp_words_by_ref -n : cur prev. But we already have cur prev from outside. But the requirement says for group 1 commands, you must use the following precise implementation to fetch and display model names. So we must have that exact code inside the case. So we need to put exactly that code block. But the requirement also says do not deviate, do not use arrays to store list of models. The code we propose uses 'local models', but that's allowed because they said do not use arrays to store the list, but a string variable is fine.
#
#So inside case for group1 we need to replicate:
#
#local cur prev
#_get_comp_words_by_ref -n : cur prev
#if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#local models
#models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#[[ -z "$models" ]] && { COMPREPLY=(); return; }
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#__ltrim_colon_completions "$cur"
#
#That's the group1 block.
#
#Now, we also need to ensure we don't use arrays incorrectly? They specifically say DO NOT use arrays to store the list of models (models must be a string). So we used local models which is string. Good.
#
#Also they said DO NOT check for existence of _get_comp_words_by_ref or __ltrim_colon_completions. So we don't need to check existence. Just call them.
#
#Also "DO NOT sort the models before passing them to compgen." In our code, we call compgen with $models unsorted. We only sort COMPREPLY after compgen. That's fine.
#
#Also we need to register completion function at end with complete -F _ollama_completions ollama.
#
#Now, we need to ensure that we handle case when subcommand might not be the previous word because maybe there is more than one word? For typical completions, after the subcommand, user will type argument; we need to detect subcommand correctly. The subcommand is the first word after ollama. So prev is subcommand. That is fine.
#
#But we need to handle when user hasn't typed subcommand yet: e.g., "ollama <TAB>" -> prev is "ollama" and cur is empty. We handle that earlier.
#
#What about when user typed "ollama run <TAB>"? prev is "run" and cur is empty; case will match show|run|... and run group1 code, but we need to fetch models. That's fine.
#
#Edge: If user typed "ollama run foo <TAB>"? prev is "foo" (argument). Then subcmd will be "foo" which doesn't match any case, so we will go to *) and set COMPREPLY=() return. That might be acceptable.
#
#But maybe we should check first word: we can check $1 or something. But that's fine.
#
#Also for create flags, the completion should provide flags. But if subcommand is create, and user typed "ollama create --" then prev is "create". That will match case create and provide flags. That's good.
#
#But we might want to handle when prev is flag like "--file". But not necessary.
#
#Now we need to make sure we use local variables properly. We can declare local cur prev inside the function at top. Then inside case for group1 we redeclare again. That might shadow but fine.
#
#Alternatively, we can use a single local cur prev and not redeclare inside group1; but requirement says we must use exact code block, which includes local cur prev. So we must redeclare.
#
#Now ensure we include brief inline comments to explain key parts.
#
#Ok, produce code.
#
#Let's craft the Bash function.
#
#Will use:
#
#function _ollama_completions() { ... }
#
#But not necessary to use function keyword; but fine.
#
#Add inline comments: # Top-level completion: list subcommands if at first word.
#
#Add comment for group1 logic: # Group 1: model completion.
#
#Ok.
#
#Now produce final output: raw Bash code.
#
#Let's write final.
#...done thinking.

function _ollama_completions() {
    local cur prev
    # Get the current and previous words in the command line
    _get_comp_words_by_ref -n : cur prev

    # Top-level: if the previous word is 'ollama', suggest subcommands
    if [[ $prev == ollama ]]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
        return
    fi

    # Determine the subcommand (first argument after ollama)
    local subcmd=$prev

    case "$subcmd" in
        # Group 1: Commands that need model name completion
        show|run|stop|push|cp|rm)
            # ---- Model name completion logic (exact steps) ----
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=(); return
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;

        # Group 2: create command with special flag completion
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;

        # Group 3: Commands that do not take arguments
        serve|pull|signin|signout|list|ps|help)
            COMPREPLY=(); return
            ;;

        # Unknown subcommand
        *)
            COMPREPLY=(); return
            ;;
    esac
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama