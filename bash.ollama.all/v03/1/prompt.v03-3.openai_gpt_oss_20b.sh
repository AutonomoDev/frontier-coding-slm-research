# Thinking...
# We need to write a bash completion script for ollama command. The function name _ollama_completions. Must use case statement switching on subcommand. Need top-level completion: if previous word is 'ollama', provide list of all subcommands. We need to handle subcommands that require model completion, and those with special flags. For flags, we need to handle after the model. For some commands with no arguments, just return empty completion.
# 
# We also need special behavior: For stop, run ollama ps to get models for completion.
# 
# We must adhere to the steps for model completion exactly as given.
# 
# We also need to use _get_comp_words_by_ref -n : cur prev inside group1 logic. For other groups we might not need that, but we can still use it.
# 
# We must register completion at the end: complete -F _ollama_completions ollama
# 
# We must not use arrays for models; we must use string.
# 
# Also must not check for existence of functions.
# 
# We need to handle group1 commands: show, run, stop, push, cp, rm.
# 
# But note run is also in group2. There is conflict: run appears in group1 and group2. According to spec, group1 commands requiring <MODEL> completion: show, run, stop, push, cp, rm. Group2 includes run again with flags. But group1 says we must use the exact implementation to fetch and display model names. So for run we must apply that. But group2 also says flags are always after the model. So for run we need to provide model completions first, then after model, flags. So logic: if current word is after model and next word is flag, provide flags. But we need to detect if prev word is a flag or model. Let's think.
# 
# We can use _get_comp_words_by_ref -n : cur prev to get cur and prev words.
# 
# We then check subcommand.
# 
# For commands requiring model completion: show, run, stop, push, cp, rm. For run, we need to also provide flags after model. We can handle by if cur starts with '-', then we provide flags; else provide model completions.
# 
# But we also need special behavior for stop: fetch list from ollama ps.
# 
# For stop: fetch models from ps output, similar to step A,B,C,D but use different command: ollama ps | tail -n +2 | awk '{print $1}'.
# 
# But the spec only defined group1 logic for show, run, stop, push, cp, rm. But step says must use the given precise implementation for group1. For stop, they explicitly say: For stop, run ollama ps for models to complete. So override.
# 
# Thus, for stop: similar to group1 but using ollama ps.
# 
# For create: flags --file -f --quantize -q, and flags are always after the model. Wait create has model? The spec: "Command with special flag completion: Flags are ALWAYS after the model." For create, flags after model. But create syntax likely is 'ollama create <model> [flags]'. So we need to complete model first, then flags. But group1 includes create? No. So we need to handle create separately. But create is not in group1. So we need logic: if subcommand is create, then if cur starts with '-', provide flags; else provide model names (maybe similar to group1). But we must fetch models? For create, maybe we need to provide model names to create from local? But spec says flags after model, but they didn't specify model completion. But we can still use same logic as group1: provide model names.
# 
# But group1 includes show, run, stop, push, cp, rm. For create, maybe we also need to provide model names? Probably yes.
# 
# But spec does not say create is part of group1. It might be that create has a model name after 'create', e.g., 'ollama create llama3'. So we need to provide model names. But spec doesn't provide explicit logic. However to satisfy, we can use same model completion logic as group1, but with additional flag handling.
# 
# But need to follow constraint: For group1, must use exact steps. We can use them for create as well.
# 
# Now, for group2: create, pull, run, show. They have flags. So we need to provide flags when appropriate.
# 
# Group3: serve, start, pull, signin, signout, list, ls, ps, help. For pull, but earlier they had pull with flag --insecure, but also in group3 with no arguments? Wait conflict: pull appears in group2 as a command with flag --insecure. Also group3 says 'pull' with no argument completion. But group3 includes 'pull'. That's contradictory. Which one is correct? According to spec: "Command with special flag completion: Flags are ALWAYS after the model. * pull (flags: --insecure)" So pull expects flags. Then Group3 lists pull again as no argument completion. That is inconsistent. Probably group3 list includes 'pull' mistakenly. We need to choose. I'd say 'pull' has flags. So we handle pull in group2.
# 
# But group3 includes 'pull', but maybe they mean that pull has no arguments aside from flags? So we can treat it as no completion beyond flags? Actually if pull takes no arguments (only flags), then we still need to provide flags after 'pull'. That matches group2.
# 
# Thus for pull, we provide flags after subcommand. So no model completion.
# 
# Similarly for run and show: flags after model. So we need to provide model completion first, then flags. For run, also we need to provide flags after model.
# 
# For stop, we do only model completion from ollama ps.
# 
# For push, cp, rm: model completion only, no flags.
# 
# For create: model completion and flags.
# 
# For serve, start, signin, signout, list, ls, ps, help: no completions.
# 
# We also need to handle that if user is typing after subcommand but before any argument, we provide model completions. We need to detect cur being incomplete. Use _get_comp_words_by_ref -n : cur prev.
# 
# We also need to handle that flags are after model, but if prev is a flag or cur starts with '-', then we need to provide flags, not model names.
# 
# So logic per subcommand:
# 
# Case:
# 
# - For subcommands that only need model completions: push, cp, rm. Provide model completion using group1 logic (except stop). But stop uses different command.
# 
# - For subcommands with model and flags: run, show, create. Provide model completion if cur does not start with '-'; else provide flags.
# 
# - For stop: special. Provide model completion from ollama ps if cur not starts with '-'.
# 
# - For pull: provide flags only (no model). So if cur starts with '-' then provide flags; else maybe no completions? But subcommand pull may allow no argument? We just provide flags. The spec says flags always after the model, but no model. So we treat as flags after subcommand. Provide flags if cur starts with '-'.
# 
# - For group3: no completion. So COMPREPLY=().
# 
# Edge: top-level: if first word is ollama, then we provide subcommands. Use compgen -W "list" etc.
# 
# Need list of subcommands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help. Also maybe others like 'pull' appears twice. We'll include once.
# 
# We need to list them: show run stop push cp rm create pull serve start signin signout list ls ps help.
# 
# Now, implement _ollama_completions:
# 
# ```
# _ollama_completions()
# {
#     local cur prev words cword
#     _get_comp_words_by_ref -n : cur prev
#     local first=${words[0]}
# 
#     # If this is the first word (after ollama) provide subcommands
#     if [[ ${prev} == ollama ]]; then
#         COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
#         return
#     fi
# 
#     # Determine subcommand: it's the first word after ollama
#     local subcommand=${words[1]}
# 
#     case "$subcommand" in
#         push|cp|rm)
#             # Use group1 logic for models
#             ...
#             ;;
#         stop)
#             # special: models from ollama ps
#             ...
#             ;;
#         run|show|create)
#             # if cur starts with - => flags
#             if [[ $cur == -* ]]; then
#                 # provide flags specific to subcommand
#                 case "$subcommand" in
#                     run) COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") );;
#                     show) COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") );;
#                     create) COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") );;
#                 esac
#                 return
#             else
#                 # Provide model completion using group1 logic
#                 ...
#             fi
#             ;;
#         pull)
#             # only flags
#             if [[ $cur == -* ]]; then
#                 COMPREPLY=( $(compgen -W "--insecure" -- "$cur") ); return
#             else
#                 COMPREPLY=(); return
#             fi
#             ;;
#         serve|start|signin|signout|list|ls|ps|help)
#             COMPREPLY=(); return
#             ;;
#         *)
#             COMPREPLY=(); return
#             ;;
#     esac
# }
# ```
# 
# But need to incorporate the group1 logic exactly for show, run, push, cp, rm? But for show and run we handle flags case. But when cur does not start with '-', we need to provide model completion using group1 logic for show and run. That logic must be exactly as provided.
# 
# Similarly for push, cp, rm: just group1 logic.
# 
# Stop: special logic using ollama ps.
# 
# Implement group1 logic:
# 
# ```
# local cur prev
# _get_comp_words_by_ref -n : cur prev
# if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
# local models
# models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
# [[ -z "$models" ]] && { COMPREPLY=(); return; }
# COMPREPLY=($(compgen -W "$models" -- "$cur"))
# COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# __ltrim_colon_completions "$cur"
# ```
# 
# But we already have cur, prev set at top. So we don't need to re-get them.
# 
# However for stop: need similar but fetch models from `ollama ps`.
# 
# So for stop we can:
# 
# ```
# local cur prev
# _get_comp_words_by_ref -n : cur prev
# if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
# local models
# models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
# [[ -z "$models" ]] && { COMPREPLY=(); return; }
# COMPREPLY=($(compgen -W "$models" -- "$cur"))
# COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# __ltrim_colon_completions "$cur"
## 
# But note: For stop, we should not use __ltrim_colon_completions? The spec didn't mention but it's fine to include same steps.
# 
# But we must not use arrays to store models; the string variable `models` is a string. That's fine.
# 
# Need to not use arrays for models.
# 
# In compgen, we pass string.
# 
# Now for group1 logic inside push, cp, rm, show, run (when cur not flag). We use same steps.
# 
# But we need to ensure we are not redefining local cur, prev incorrectly. Since we already defined at start, we can reuse.
# 
# But the steps mention local cur prev again; but we could just use existing variables. But to follow "Step A: Extract Word Info" we may include the same line again. That might reinitialize cur and prev to same values. That is fine.
# 
# Thus we can embed the steps exactly.
# 
# Similarly for stop.
# 
# Now we need to provide flags for run, show, create. Provide appropriate flag strings.
# 
# Also for create: flags are `--file`, `-f`, `--quantize`, `-q`.
# 
# For run: flags: `--format`, `--hidethinking`, `--insecure`, `--keepalive`, `--nowordwrap`, `--think`, `--verbose`.
# 
# For show: flags: `--license`, `--modefile`, `--parameters`, `--system`, `--template`, `--verbose`.
# 
# For pull: flag `--insecure`.
# 
# For group3 commands: no completion.
# 
# Also need to handle if cur is empty (user pressed Tab at the end), still provide completions.
# 
# Edge: For group2 commands, if cur is empty and prev is subcommand (no model yet), we need to provide model completion. That will happen in the else block of flags case.
# 
# Also for stop: if cur empty and prev is stop, we provide model completion.
# 
# For group3 commands: if cur empty after subcommand, we return empty completion.
# 
# We also need to handle when user types subcommand with no arguments: e.g., "ollama push ". In this case cur is empty, prev is push. We should provide model completions. That works.
# 
# Now we need to register function.
# 
# Now, need to include __ltrim_colon_completions: that's a bash completion helper function to remove trailing colon. It's called after sorting. So we need to include that call.
# 
# All good.
# 
# One potential conflict: The initial top-level completion: if previous word is 'ollama', provide subcommands. But if user typed 'ollama ' and cur empty, prev will be 'ollama', so that triggers subcommand list. Good.
# 
# But if user typed 'ollama show ' and cur empty, prev is 'show', not 'ollama', so the top-level condition won't trigger. Then subcommand logic will handle.
# 
# Now, we need to define the function and register it.
# 
# Let's craft the code.
# 
# We need to include _get_comp_words_by_ref -n : cur prev for each group1 block. We might duplicate but it's fine.
# 
# We also need to define local variables within each block, but not conflict with outer local. We can use new local variables.
# 
# Now, implement function.
# 
# ```
# _ollama_completions()
# {
#     local cur prev words cword
#     _get_comp_words_by_ref -n : cur prev words cword
# 
#     # If the last word is 'ollama', suggest subcommands
#     if [[ $prev == ollama ]]; then
#         COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
#         return
#     fi
# 
#     # Identify the subcommand (second word)
#     local subcommand=${words[1]}
# 
#     case "$subcommand" in
#         push|cp|rm)
#             # Group1 model completion logic
#             local cur prev
#             _get_comp_words_by_ref -n : cur prev
#             if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#             local models
#             models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#             [[ -z "$models" ]] && { COMPREPLY=(); return; }
#             COMPREPLY=($(compgen -W "$models" -- "$cur"))
#             COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#             __ltrim_colon_completions "$cur"
#             return
#             ;;
#         stop)
#             # Special: models from ollama ps
#             local cur prev
#             _get_comp_words_by_ref -n : cur prev
#             if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#             local models
#             models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
#             [[ -z "$models" ]] && { COMPREPLY=(); return; }
#             COMPREPLY=($(compgen -W "$models" -- "$cur"))
#             COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#             __ltrim_colon_completions "$cur"
#             return
#             ;;
#         run|show|create)
#             # If user is typing a flag
#             if [[ $cur == -* ]]; then
#                 case "$subcommand" in
#                     run) COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") );;
#                     show) COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") );;
#                     create) COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") );;
#                 esac
#                 return
#             else
#                 # Provide model completion using group1 logic
#                 local cur prev
#                 _get_comp_words_by_ref -n : cur prev
#                 if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#                 local models
#                 models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#                 [[ -z "$models" ]] && { COMPREPLY=(); return; }
#                 COMPREPLY=($(compgen -W "$models" -- "$cur"))
#                 COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#                 __ltrim_colon_completions "$cur"
#                 return
#             fi
#             ;;
#         pull)
#             if [[ $cur == -* ]]; then
#                 COMPREPLY=( $(compgen -W "--insecure" -- "$cur") ); return
#             else
#                 COMPREPLY=(); return
#             fi
#             ;;
#         serve|start|signin|signout|list|ls|ps|help)
#             COMPREPLY=(); return
#             ;;
#         *)
#             COMPREPLY=(); return
#             ;;
#     esac
# }
# complete -F _ollama_completions ollama
# ```
# 
# But we used local cur prev defined at start; then we redefined them in blocks. That's okay.
# 
# However, we might want to avoid duplicate local variable definitions of cur, prev that may shadow outer ones; but since they are local to function, it's fine.
# 
# Now, we need to consider that we used local cur prev at start but we didn't set words or cword? _get_comp_words_by_ref sets cur and prev but also words and cword? Actually _get_comp_words_by_ref -n : cur prev uses `words` and `cword`. We need to define local words cword.
# 
# We did local cur prev words cword.
# 
# Now, after _get_comp_words_by_ref, we have words array. We need to capture subcommand as words[1].
# 
# We used local subcommand=${words[1]}. That works.
# 
# Now the top-level check: `if [[ ${prev} == ollama ]]; then`. But words[0] is 'ollama', prev might be 'ollama' if the last word is 'ollama' and cur is next. But if user typed 'ollama ' and cur empty, prev is 'ollama', so subcommands. Good.
# 
# But if user typed 'ollama show' and cur 'show', prev might be 'ollama'? Actually when user typed 'ollama show', the last word is 'show', prev is 'ollama'. But _get_comp_words_by_ref -n : cur prev might set cur to 'show' and prev to 'ollama'? Let's examine: Suppose command line: `ollama show`. There are two words: 'ollama' and 'show'. In completion, cur is the word after current cursor position. If user typed 'ollama show' and hasn't pressed Tab yet, cur is empty (since after 'show' no space). But prev would be 'show'? Actually when pressing Tab after 'ollama show', cur is empty, prev is 'show', words[1] is 'show'. That means prev is subcommand. So top-level condition fails.
# 
# If user typed `ollama ` then cur empty, prev 'ollama', words[1] doesn't exist. Good.
# 
# Thus the top-level condition may need to be:
# 
# ```
# if [[ $prev == ollama ]]; then
## 
# But prev refers to previous word. If prev is 'ollama', that means user typed 'ollama ' and pressed Tab. So correct.
# 
# Now, we need to ensure words array is available. _get_comp_words_by_ref populates words array.
# 
# Now, we need to confirm that we correctly handle the subcommand extraction. subcommand is words[1]. That should work.
# 
# Now, we need to check that the function is registered for 'ollama' command. We'll use `complete -F _ollama_completions ollama`.
# 
# Now, we need to include the function code only. We may need to include `complete -o default -o nospace -F _ollama_completions ollama`. But default options are fine.
# 
# Now, check for missing parts: We must include __ltrim_colon_completions call. But we need to use it inside group1 logic. For stop we also call.
# 
# But we defined `__ltrim_colon_completions` only if present. It's usually part of bash completion. So we can call.
# 
# Edge: For group3 commands, we simply return empty completions. That means pressing Tab will do nothing.
# 
# Now, consider when subcommand is unknown: we return empty.
# 
# Now, test with examples:
# 
# Case 1: `ollama show -` (user typed `-` after space). cur is '-', prev is show. It matches top-level? No. subcommand show. In case run|show|create, cur starts with -, we provide flags: `--license ...`. Good.
# 
# Case 2: `ollama show` and press Tab. cur empty, prev show. It doesn't start with '-', so else block triggers group1 logic, providing model completions. Good.
# 
# Case 3: `ollama run --format` pressing Tab after `--format`. cur empty, prev is `--format`. In case run, cur starts with -, so we provide flags again. That includes `--format`. But there may be conflict: The user typed `--format` fully, pressing Tab again: cur empty, prev is `--format`. Since cur empty and starts with '-', we provide flags again, but compgen will match flags again. Good.
# 
# Case 4: `ollama stop` pressing Tab. prev is stop, subcommand stop. In case stop, cur empty, not starting with '-', so group1 logic from ollama ps executed. Good.
# 
# Case 5: `ollama pull` pressing Tab. prev is pull. Since pull expects flags only, we check if cur starts with '-'. If cur empty, we return empty completions. So pressing Tab after 'ollama pull ' will produce nothing. That is acceptable.
# 
# Case 6: `ollama push` pressing Tab. cur empty, push. Group1 logic executes. Good.
# 
# Now, we must ensure we didn't override local cur variable incorrectly. Since we defined local cur prev at start, and redefined in group1 blocks, it's fine.
# 
# We also need to not use arrays to store models. We use string `models`. In compgen, we pass string. That's fine.
# 
# Now, let's write final code with comments.
# 
# Also need to call __ltrim_colon_completions.
# 
# We must ensure we use `printf "%s\n" "${COMPREPLY[@]}" | sort`. That uses array. But we are allowed to use array for COMPREPLY; only models must not be arrays. Good.
# 
# Now, final code.
# 
# We'll produce final answer.
# ...done thinking.

_ollama_completions()
{
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # 1. If the last word is the command name itself, suggest the available
    #    sub‑commands.
    if [[ $prev == ollama ]]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull \
                                    serve start signin signout \
                                    list ls ps help" -- "$cur") )
        return
    fi

    # 2. Determine the sub‑command (the second word on the line).
    local subcommand=${words[1]}

    case "$subcommand" in

        # ---- Sub‑commands that accept a list of media types (models) ----
        push|cp|rm)
            # 3.1. Model‑type completion logic (common to push, cp, rm)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z $models ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # ---- Sub‑command that asks for the current models (stop) ----
        stop)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z $models ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # ---- Sub‑commands that support both flags and media‑type names
        #     (run, show, create) ----------------------------------------
        run|show|create)
            if [[ $cur == -* ]]; then
                case "$subcommand" in
                    run)
                        COMPREPLY=( $(compgen -W \
                            "--format --hidethinking --insecure --keepalive \
                            --nowordwrap --think --verbose" -- "$cur") );;
                    show)
                        COMPREPLY=( $(compgen -W \
                            "--license --modefile --parameters --system \
                            --template --verbose" -- "$cur") );;
                    create)
                        COMPREPLY=( $(compgen -W \
                            "--file -f --quantize -q" -- "$cur") );;
                esac
                return
            else
                # 3.2. If no flag is being typed, fall back to model‑type
                #      completion (same as push/cp/rm).
                local cur prev
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then
                    COMPREPLY=()
                    return
                fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z $models ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
                return
            fi
            ;;

        # ---- Sub‑command that only accepts a flag (pull) ----------------
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
                return
            else
                COMPREPLY=()
                return
            fi
            ;;

        # ---- Sub‑commands that accept no arguments (or not handled) ----
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;

        # ---- Unknown sub‑command ---------------------------------------
        *)
            COMPREPLY=()
            return
            ;;
    esac
}

# Enable the completion for the `ollama` command.
complete -F _ollama_completions ollama