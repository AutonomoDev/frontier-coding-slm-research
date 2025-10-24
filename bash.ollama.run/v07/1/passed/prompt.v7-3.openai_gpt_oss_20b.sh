#Thinking...
#We need to produce a Bash script that satisfies all constraints. We'll write function `_ollama_run_completion`.
#
#Key points: Use `COMP_WORDS` and `COMP_CWORD`. Find index of "run" in COMP_WORDS. Only activate if COMP_CWORD == run_index + 1.
#
#We need to temporarily remove colon from COMP_WORDBREAKS before computing matches, and restore afterwards.
#
#Need robust parsing of `ollama list`: skip header line, print first column: `awk 'NR>1 {print $1}'`.
#
#We also need to dedupe results. Use associative array: `declare -A seen`.
#
#We need to filter by current word via compgen -W.
#
#We should use `_get_comp_words_by_ref` if available, else fallback: cur=${COMP_WORDS[COMP_CWORD]}. But we need to handle colons: we should set `-n :`? Actually, the spec says we can pass -n : to _get_comp_words_by_ref, but still need to adjust COMP_WORDBREAKS. So we could do: `_get_comp_words_by_ref -n : cur prev`. But better to just fallback: cur=${COMP_WORDS[COMP_CWORD]}. Then we need to restore COMP_WORDBREAKS before exiting.
#
#We also need to handle case when `ollama list` fails or outputs nothing: quiet exit (no errors, no suggestions). So if wordlist is empty after dedupe, COMPREPLY=() and exit.
#
#Also we must not use -o default or -o bashdefault. So complete registration: `complete -F _ollama_run_completion ollama`.
#
#Need to ensure we don't return any suggestion if none matches. Use compopt -o nospace maybe? We don't need to modify.
#
#Also ensure that COMPREPLY gets list of suggestions only for the current word. Use compgen -W "$wordlist" -- "$cur".
#
#Dedup: we can use array and associative.
#
#Also need to ensure we don't provide filename fallback. By default, if COMPREPLY is empty, Bash might fall back to filename completion. But we need to disable that. We can set `compopt -o default`? Wait spec: "No Filename Fallback: If no models match, provide no suggestions and do not fall back to files. When registering completion, do not use -o default or -o bashdefault." So we must disable fallback. In Bash completion, if COMPREPLY is empty, by default it might fallback to filenames. But we can set `compopt -o default`? Actually -o default is enabling default fallback. So we don't set that. But we might need to set `compopt -o nospace`? That just controls trailing space. But fallback may still happen. Actually by default, Bash fallback to filenames if no matches and not -o default. But if no matches, COMPREPLY empty, Bash will try to complete filenames. We want to avoid that. We can use `compopt -o nospace`? No. There is option `-o default` to enable fallback; we don't set. But default behavior might still fallback. I'm not sure. But maybe we need to set `compopt -o default`? Wait spec: "No Filename Fallback: If no models match, provide no suggestions and do not fall back to files." So we need to disable fallback. That means we need to use `compopt -o default`? Actually default fallback is `-o default`. So we should not set -o default. But fallback might still happen even without -o default? I think fallback to files occurs if completion returns empty and option -o default is set. Without -o default, it doesn't. So we are fine.
#
#However, we might want to add `compopt -o nospace` to not add space after completion. Not necessary but fine.
#
#Important: Must restore COMP_WORDBREAKS before returning, even if early exit. So we can set trap or ensure we always restore at end. We'll use local variable to save old_wb, then use `return` after restore. Use a function that will restore at the end using `trap`? Easiest: Save old_wb, then set new one, then at end, before return, set back old_wb. We'll structure code to ensure all return paths restore.
#
#Let's craft script:

#!/usr/bin/env bash
# Bash completion for ollama run models
# ...
#_ollama_run_completion() {
#    local old_wb=$COMP_WORDBREAKS
#    # Temporarily remove colon from word breaks
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
#    # Find index of "run" in COMP_WORDS
#    local run_index=-1
#    local i
#    for ((i=0; i<COMP_CWORD; i++)); do
#        if [[ ${COMP_WORDS[i]} == "run" ]]; then
#            run_index=i
#            break
#        fi
#    done
#
#    # If not found or not the correct token, restore and exit
#    if [[ $run_index -eq -1 || $COMP_CWORD -ne $((run_index+1)) ]]; then
#        COMP_WORDBREAKS=$old_wb
#        return
#    fi
#
#    # Get current word being typed
#    local cur
#    if type -p _get_comp_words_by_ref &>/dev/null; then
#        _get_comp_words_by_ref -n : cur
#    else
#        cur=${COMP_WORDS[COMP_CWORD]}
#    fi
#
#    # Fetch list of models
#    local wordlist
#    if ! wordlist=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
#        COMP_WORDBREAKS=$old_wb
#        return
#    fi
#
#    # If wordlist empty, restore and exit
#    if [[ -z $wordlist ]]; then
#        COMP_WORDBREAKS=$old_wb
#        return
#    fi
#
#    # Deduplicate and filter by cur
#    local -A seen
#    local -a filtered
#    local model
#    while IFS= read -r model; do
#        if [[ -z ${seen[$model]} ]]; then
#            seen[$model]=1
#            filtered+=("$model")
#        fi
#    done <<< "$wordlist"
#
#    # Generate completions
#    COMPREPLY=($(compgen -W "${filtered[*]}" -- "$cur"))
#
#    # Restore COMP_WORDBREAKS
#    COMP_WORDBREAKS=$old_wb
#}
#complete -F _ollama_run_completion ollama
#```
#
#But we need to ensure that we don't add any fallback. Also we used `compgen -W "${filtered[*]}"`. This passes all names; compgen will filter. Should be fine.
#
#But we used `COMP_WORDBREAKS` temporarily. After we restore, it's fine.
#
#Edge cases: We must ensure no early returns before restoring. We returned in case run_index -1 or not matched; we restored before returning.
#
#Also if `ollama list` fails, we restored before returning.
#
#Also if wordlist empty, restored.
#
#Now, potential issue: We used `if ! wordlist=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then` but if command fails, the exit status is non-zero, and wordlist will be empty? Actually the assignment will still succeed but with empty string. But we check exit status, we call `! wordlist=$(...)`? That uses command substitution inside the if. `! wordlist=$(...)` will assign to variable and check status of assignment? Actually, `!` is negation of exit status of the pipeline. So if pipeline exits 0, ! will make it 1, causing if to be true? That is wrong. We need to capture output and then check exit status of command. Do like:
#
#```
#if ! wordlist=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
#```
#
#But `!` applied to the assignment? Wait `!` negates the exit status of the pipeline that follows. So here pipeline is `ollama list 2>/dev/null | awk 'NR>1 {print $1}'`. The assignment is outside the pipeline? Actually, `wordlist=$(...)` is part of the pipeline? No, it's separate. The pipeline ends before the assignment. So we have `if ! wordlist=$(command); then`. The `!` negates exit status of `wordlist=$(command)`. But `wordlist=$(command)` returns exit status of command? In Bash, assignment commands return status of the right-hand side? I think it returns status of the command substitution. So `wordlist=$(cmd)` returns exit status of cmd. So using `!` will invert. So if command succeeded (status 0), `!` yields 1, if it fails, yields 0. So our if will execute when command succeeded. That's wrong. So we need to handle differently: Do
#
#```
#if ! wordlist=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
#    ...
#fi
#```
#
#This is exactly what we wrote. Wait but we said earlier that it inverts? Let's test mentally: Suppose `ollama list` fails: exit status 1. `wordlist=$(command)` returns 1. `! 1` is 0 (true). So if block executes. That's desired. Suppose success: exit status 0. `wordlist=$(command)` returns 0. `! 0` is 1 (false). So if block not executed. That's fine. So our code is correct. Good.
#
#But we must also handle case where wordlist is empty string because output had nothing. Then `wordlist=$(... )` might still return 0 because pipeline succeeded but produced nothing. That would not go into if block. Then we check `if [[ -z $wordlist ]]; then`. That's fine.
#
#Now dedupe: we read each line and use associative array. But if there are duplicate names (unlikely). We use read -r model, and check if seen. That's fine.
#
#We then generate COMPREPLY with compgen. However, if no matches found by compgen, COMPREPLY will be empty. That's fine.
#
#But we must ensure we don't inadvertently trigger file completion fallback. By default, if COMPREPLY empty and no fallback options set, Bash may still try filename completion? I think fallback only occurs if -o default or -o bashdefault set. So we are fine.
#
#But we might want to use `compopt -o nospace`? Not required. But we can add.
#
#But spec: "When registering completion, do not use -o default or -o bashdefault." We didn't. Good.
#
#Also ensure we don't use `-o default` or `-o nospace`. So fine.
#
#One more: The function uses `COMP_WORDBREAKS` modifications. But we must ensure we restore it even when we exit early. We do.
#
#But we need to ensure that the variable is local? In Bash, `COMP_WORDBREAKS` is global; we don't need local. But we can local old_wb. That is fine.
#
#Also, we need to include shebang? The script may be sourced. Not necessary, but okay to have.
#
#Let's produce final script.
#
#We should comment each line. Ensure every line of non-code starts with '#'.
#
#We need to output only the script. Let's generate.
#...done thinking.

#!/usr/bin/env bash
# Bash completion script for `ollama run` that suggests local model names.
# The script is intended to be sourced: `source my_script.sh`.

# ----------------------------------------------------------------------
# Core completion function
# ----------------------------------------------------------------------
_ollama_run_completion() {
    # Preserve the original word break settings.
    local old_wb=$COMP_WORDBREAKS
    # Temporarily remove ':' from word breaks so that model names with colons
    # are treated as a single word.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Find the index of the literal word "run" in COMP_WORDS.
    local run_index=-1
    local i
    for ((i=0; i<COMP_CWORD; i++)); do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # If "run" was not found or the current token is not the one immediately
    # after "run", restore word breaks and exit without doing anything.
    if [[ $run_index -eq -1 || $COMP_CWORD -ne $((run_index+1)) ]]; then
        COMP_WORDBREAKS=$old_wb
        return
    fi

    # Determine the current word being typed. Use the standard helper if it
    # is available, otherwise fall back to a simple assignment.
    local cur
    if type -p _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur
    else
        cur=${COMP_WORDS[COMP_CWORD]}
    fi

    # Retrieve the list of local models from `ollama list`, ignoring errors.
    local wordlist
    if ! wordlist=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
        # If the command failed, clean up and exit.
        COMP_WORDBREAKS=$old_wb
        return
    fi

    # If the list is empty (no output from `ollama list`), clean up and exit.
    if [[ -z $wordlist ]]; then
        COMP_WORDBREAKS=$old_wb
        return
    fi

    # Deduplicate the model names (in case duplicates appear) and store
    # them in an array for later use.
    local -A seen
    local -a filtered
    local model
    while IFS= read -r model; do
        if [[ -z ${seen[$model]} ]]; then
            seen[$model]=1
            filtered+=("$model")
        fi
    done <<< "$wordlist"

    # Generate the list of completions that match the current word.
    COMPREPLY=($(compgen -W "${filtered[*]}" -- "$cur"))

    # Restore the original word break settings before returning.
    COMP_WORDBREAKS=$old_wb
}

# ----------------------------------------------------------------------
# Register the completion function with the `ollama` command.
# ----------------------------------------------------------------------
complete -F _ollama_run_completion ollama

# End of script.

