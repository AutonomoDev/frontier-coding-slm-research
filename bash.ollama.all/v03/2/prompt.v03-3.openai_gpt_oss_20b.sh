# Thinking...
# We need to generate a single function _ollama_completions implementing completion for ollama command, following exact requirements.
#
# Requirements:
#
# - Use case statement for subcommands.
# - Top-level: if previous word is ollama provide subcommand list. For that we need to detect first word or if comp_words[0] is ollama.
#
# But we are using _get_comp_words_by_ref. Standard completion functions: _get_comp_words_by_ref is used to set cur prev and also the first word? Actually _get_comp_words_by_ref -n : cur prev gets current word and previous word, not first word. For top-level we need to see if WORDS[0] is ollama? Wait the default behavior for bash completions: the command being completed is 'ollama', and the words are after it. The function is called with current word cur and prev, but we need to determine if we are at top level (first subcommand). Usually we check if [[ ${#COMP_WORDS[@]} -eq 2 ]] meaning after the command, but we can simply list subcommands when prev is ollama? But prev would be 'ollama'? No, prev is previous word before the current incomplete word. At the start, WORDS[1] is the first subcommand. If the user typed 'ollama ' and then pressed tab, cur would be empty string and prev would be 'ollama'. So checking if [[ $prev == "ollama" ]] we should suggest subcommands. That matches requirement: "If the previous word is ollama, provide a list of all subcommands as completions."
#
# Thus we implement: if [[ $prev == "ollama" ]]; then COMPREPLY=($(compgen -W "..." -- "$cur")); return; fi
#
# Now we need subcommand list: All subcommands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help? Actually group 3 includes: serve, start, pull, signin, signout, list, ls, ps, help. Also group 2 includes create, pull, run, show (but some flags). Group 1 includes show, run, stop, push, cp, rm. Notice pull is in group 3 and also group 2? The spec says "Command with special flag completion: Flags are ALWAYS after the model. * `create` (flags...), `pull` (flags...), `run` (flags...), `show` (flags...)" So pull also has flags. But group 3 says "Commands with no argument completion: serve, start, pull, signin, signout, list, ls, ps, help". Conflict: pull both has flags and also no argument completion? But likely the intention is that pull has flags but no arguments; but for completions we just provide flags. The group 3 may be a mistake; but we should support flags for pull as defined. So we need to handle pull flags.
#
# Also we need for stop: run `ollama ps` to get models.
#
# We need to implement case on the first subcommand. How to get subcommand? Using COMP_WORDS array. After we get cur and prev, we can compute the subcommand as $COMP_WORDS[1] or something. But we can use the first word after ollama: subcommand=${COMP_WORDS[1]}. So:
#
# local subcommand=${COMP_WORDS[1]}
#
# Then case $subcommand in ... )
#
# But need to consider if the user typed multiple subcommands? Typically only one subcommand. So we can just use first word.
#
# Group 1 commands: show, run, stop, push, cp, rm: require model completion.
#
# For each of these, we need to follow exact steps for model completion. But for stop, we need to run ollama ps instead of ollama list. So for stop we need a different logic. The spec says: "For stop, run `ollama ps` for models to complete, which gives ...". So we need to adjust.
#
# The group 1 includes show and run but show also has flags; we need to handle flags after model? For show: flags always after model. So we need to detect if cur is after model? Actually for show, the model name is required before flags. So if the user types "ollama show " and then tab, the cur is empty and prev is "show". We should provide model completions. If the user typed "ollama show gemma3:270m " and pressed tab, then cur is empty and prev is the model, and we should provide flags. So need to handle that. But the requirement only says for Group 1 commands, use the model completion logic. But for show/run, flags are after model. So we need to handle flags after model. We need to differentiate between when cur is the model or flag. In typical completions, we check if the previous word starts with '-' or if the cur begins with '-'? But cur is what the user is typing; if they type a '-' then we should provide flags. So we can check if [[ $cur == -* ]]; then provide flags. For commands that support flags after model: create, pull, run, show. But for create and pull, they also have flags; but create needs to support flags after model? Wait create takes model as first argument, then flags. Pull takes no model but flags? But spec says flags always after the model. For pull, model is not needed; but they say flags are ALWAYS after the model; maybe for pull flags can appear anywhere? Usually pull has flags that apply to pulling, not after model. But maybe they incorrectly say. We'll just provide flags when cur starts with '-' for pull.
#
# Simplify: For commands that have flags (create, pull, run, show), we can handle flag completion if cur starts with '-'. Provide appropriate flag list.
#
# Also, for create we need to handle --file/-f and --quantize/-q.
#
# pull: --insecure
#
# run: --format, --hidethinking, --insecure, --keepalive, --nowordwrap, --think, --verbose
#
# show: --license, --modefile, --parameters, --system, --template, --verbose
#
# Also, we should not provide model completions for these flags; they should not appear.
#
# Now we need to handle model completion for commands show, run, stop, push, cp, rm, but for stop we need to use ps. Also for show and run, they have flags after model. So we need to detect if cur starts with '-' or if prev is one of those commands? Actually if cur starts with '-', we provide flags. That works.
#
# But for show and run, if cur is not starting with '-', we should provide model completions. For stop, always provide model completions from ollama ps. For push, cp, rm, we just provide model completions from ollama list. For pull, no models.
#
# Edge case: if user typed 'ollama run -' we should provide flags. If they typed 'ollama run model -', we should also provide flags. That is fine.
#
# Implementation plan:
#
# Define subcommands list:
#
# subcommands=("show" "run" "stop" "push" "cp" "rm" "create" "pull" "serve" "start" "signin" "signout" "list" "ls" "ps" "help")
#
# Case:
#
# case "$subcommand" in
#
# show|run|stop|push|cp|rm)
#    # if cur starts with '-' -> flags (only for show/run)
#    if [[ $cur == -* ]]; then
#       # flags for show or run depending on subcommand
#       case "$subcommand" in
#          show) flags="--license --modefile --parameters --system --template --verbose";;
#          run) flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose";;
#          *) flags="";; # others no flags
#       esac
#       COMPREPLY=($(compgen -W "$flags" -- "$cur"))
#       return
#    fi
#
#    # otherwise model completion
#    if [[ $subcommand == stop ]]; then
#        # use ollama ps
#        local cur prev
#        _get_comp_words_by_ref -n : cur prev
#        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#        local models
#        models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
#        [[ -z "$models" ]] && { COMPREPLY=(); return; }
#        COMPREPLY=($(compgen -W "$models" -- "$cur")))
#    else
#        # use ollama list
#        local cur prev
#        _get_comp_words_by_ref -n : cur prev
#        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#        local models
#        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#        [[ -z "$models" ]] && { COMPREPLY=(); return; }
#        COMPREPLY=($(compgen -W "$models" -- "$cur"))
#    fi
#    # sort and trim
#    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#    __ltrim_colon_completions "$cur"
#    return
#    ;;
# create)
#    if [[ $cur == -* ]]; then
#       COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
#       return
#    fi
#    # No model needed, but maybe flags after model? no. Provide nothing.
#    COMPREPLY=()
#    return
#    ;;
# pull)
#    if [[ $cur == -* ]]; then
#       COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
#       return
#    fi
#    COMPREPLY=()
#    return
#    ;;
# serve|start|signin|signout|list|ls|ps|help)
#    COMPREPLY=()
#    return
#    ;;
# *)
#    COMPREPLY=()
#    return
#    ;;
# esac
#
# But we need to also ensure top-level completion: if $prev == "ollama" then subcommand list.
#
# Add at top:
#
# local cur prev
# _get_comp_words_by_ref -n : cur prev
# if [[ $prev == "ollama" ]]; then
#    COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
#    return
# fi
#
# But subcommands must be defined earlier.
#
# We must also handle that for stop command, we should use ollama ps. The output sample shows first column NAME (model). We need to parse the first column.
#
# Implementation for stop: models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}').
#
# Also for list: use ollama list. The sample shows first column NAME.
#
# The code must not use arrays to store models; we use string variable models.
#
# Also do not sort before compgen. We need to sort after compgen. For stop we need to use compgen -W "$models" -- "$cur" before sorting. That matches requirement. We must not sort before.
#
# Also we must not add fallback logic; but we have early return when command not found or no models.
#
# Edge: We call _get_comp_words_by_ref multiple times; that's okay but we should ensure we don't redeclare cur and prev? The spec says to use Step A exactly: local cur prev; _get_comp_words_by_ref -n : cur prev. So we should implement exactly that in each branch where we need it. But for top-level we also need to get cur and prev. They didn't specify but we need them. However we may need to call it earlier; we might call it once at beginning of function. But step A is required for Group 1; they say must use that precise implementation. So we should include that inside each branch that uses model completion logic.
#
# But we could call it once at top, then re-use cur and prev. But to satisfy the requirement, we need to call that code snippet inside each branch, but we can also call it at top? The requirement: "For the commands listed in Group 1 (`show`, `run`, etc.), you must use the following precise implementation to fetch and display model names. Do not deviate." The snippet includes step A. It expects to run _get_comp_words_by_ref. So we need to use that snippet within the branch for those commands.
#
# Thus for each group 1 command, we should do:
#
# case "$subcommand" in
#   show|run|push|cp|rm)
#     local cur prev
#     _get_comp_words_by_ref -n : cur prev
#     if [[ $cur == -* ]]; then
#         # flag logic
#     fi
#     # rest
#   ;;
#   stop)
#     local cur prev
#     _get_comp_words_by_ref -n : cur prev
#     # ...
#   ;;
# esac
#
# Ok.
#
# Also we need to handle flags for show/run within that branch after Step A. But the flag logic uses $cur to decide; but we already have cur.
#
# Implementation details:
#
# For show and run, we need flags. But for push, cp, rm there are no flags; but we might accidentally produce flags if cur starts with '-'. But they are not specified to have flags, but we can just ignore. So we only add flag logic if subcommand is show or run.
#
# So inside case for show|run|stop|push|cp|rm we can handle:
#
# if [[ $cur == -* ]]; then
#    case "$subcommand" in
#        show) flags="--license --modefile --parameters --system --template --verbose";;
#        run) flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose";;
#        *) flags="";;
#    esac
#    if [[ -n $flags ]]; then
#       COMPREPLY=($(compgen -W "$flags" -- "$cur"))
#       return
#    fi
# fi
#
# Then proceed to model completion.
#
# Edge: For stop, we should not provide flags.
#
# Now for create and pull, we need flag logic; also they may not require a model, but we could provide nothing.
#
# Now implement final code.
#
# We also need to register completion at end: complete -F _ollama_completions ollama
#
# Add brief inline comments.
#
# Ensure no array for models; we use string.
#
# We must ensure that __ltrim_colon_completions function is called after sorting. That's part of step D.
#
# Now produce final code.
# ...done thinking.

# Bash completion function for ollama
_ollama_completions() {
    local subcommands="show run stop push cp rm create pull serve start signin signout list ls ps help"
    local cur prev

    # Top‑level: complete the subcommand list when user types `ollama `
    _get_comp_words_by_ref -n : cur prev
    if [[ $prev == "ollama" ]]; then
        COMPREPLY=($(compgen -W "${subcommands}" -- "$cur"))
        return
    fi

    subcommand="${COMP_WORDS[1]}"

    case "$subcommand" in
        # Commands that need model completion (Group 1)
        show|run|push|cp|rm)
            # Step A: obtain the current word
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            # If the user typed a flag, complete the appropriate flag list
            if [[ $cur == -* ]]; then
                local flags
                case "$subcommand" in
                    show) flags="--license --modefile --parameters --system --template --verbose" ;;
                    run)  flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" ;;
                    *)    flags="" ;;
                esac
                if [[ -n $flags ]]; then
                    COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                    return
                fi
            fi
            # Step B: fetch model names from `ollama list`
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z $models ]] && { COMPREPLY=(); return; }
            # Step C: provide completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            # Step D: sort and trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # `stop` uses `ollama ps` instead of `ollama list`
        stop)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z $models ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # Commands that support flags but no model
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
                return
            fi
            COMPREPLY=()
            return
            ;;

        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
                return
            fi
            COMPREPLY=()
            return
            ;;

        # Simple commands with no further arguments
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;

        # Fallback for unknown commands
        *)
            COMPREPLY=()
            return
            ;;
    esac
}
complete -F _ollama_completions ollama
