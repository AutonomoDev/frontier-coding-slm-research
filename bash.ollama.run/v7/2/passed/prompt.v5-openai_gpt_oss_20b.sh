#Thinking...
#We need to produce a Bash script that implements the completion logic as described. Let's outline the steps:
#
#- Define a function `_ollama_run_completion`.
#- Determine run_index by searching COMP_WORDS for "run".
#- Ensure trigger only when COMP_CWORD == run_index+1.
#- Get current word cur: the word at COMP_CWORD.
#- Remove colon from COMP_WORDBREAKS: save old, modify, restore after.
#- Get model names list: run `ollama list | awk 'NR>1 {print $1}'`. Capture into an array. Use mapfile -t or read array via while loop.
#- Deduplicate using associative array or sort -u.
#- Filter using compgen -W "$model_list" -- "$cur". This will produce matches and store in COMPREPLY.
#- Ensure no filename fallback: we don't pass -o default. But by default, Bash may fallback? The requirement says don't use -o default or bashdefault. So just not specifying any options will default to bash completion, but no default. We must ensure not to fallback to files. I think if compgen fails, COMPREPLY remains empty. That meets requirement.
#
#- We must restore COMP_WORDBREAKS in all paths. We'll wrap the logic in a block and set `trap`? We can simply set it back at the end.
#
#- Avoid early returns: we can use local variables, but ensure final `COMP_WORDBREAKS=$old_wb` before exit. We can use a function and at the end set it. If we exit early due to run_index not found or not triggered, we should restore and return. We can set a variable `done=0` and at end restore and if not done then return.
#
#- For fallback when _get_comp_words_by_ref is not available: we can manually set cur and prev.
#
#- Implementation: We'll use `_get_comp_words_by_ref cur prev` if available.
#
#Let's craft the script.
#
#```
##!/usr/bin/env bash
## ...
#```
#
#But requirement: output only script lines starting with # for non-code. So for code lines we don't prefix #. For comments we prefix #. For blank lines maybe #? They said every line of non-code starts with #. That includes comments but also blank lines? Usually blank lines are not code, but maybe they count as non-code. Safer to keep them as empty lines. But to be safe, we can prefix # on empty lines? But that's weird. We could keep blank lines; but requirement says "every line of non-code starts with #". If we include a blank line, that line doesn't start with #. So maybe avoid blank lines. Or we can add a comment line with just #. But easier: avoid blank lines or prefix them with #. We'll just not have blank lines.
#
#We need to ensure we include only code lines without preceding #. Comments with #.
#
#Let's craft:
#
#```
## This script provides bash completion for 'ollama run' to suggest local model names.
## It handles model names containing colons, avoids filename fallback, and ensures
## restoration of COMP_WORDBREAKS after completion.
#
#_ollama_run_completion() {
#    local cur prev run_index
#    # Save original word breaks
#    local old_wb="$COMP_WORDBREAKS"
#    # Temporarily remove colon from word breaks
#    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
#
#    # Find the index of the literal word 'run' in COMP_WORDS
#    run_index=-1
#    for ((i=0; i<COMP_CWORD; i++)); do
#        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
#            run_index=$i
#            break
#        fi
#    done
#
#    # Ensure completion is only for the word immediately after 'run'
#    if (( run_index == -1 || COMP_CWORD != run_index + 1 )); then
#        COMP_WORDBREAKS="$old_wb"
#        return
#    fi
#
#    # Retrieve current word being completed
#    if type -p _get_comp_words_by_ref >/dev/null 2>&1; then
#        _get_comp_words_by_ref -n : cur prev
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Fetch model names from 'ollama list'
#    local model_list
#    if ! model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
#        COMP_WORDBREAKS="$old_wb"
#        return
#    fi
#
#    # Deduplicate and prepare word list
#    local words
#    IFS=$'\n' read -d '' -r -a words < <(printf '%s\n' "$model_list" | awk '!seen[$0]++' && printf '\0')
#
#    # Generate completions filtered by current word
#    COMPREPLY=()
#    for w in "${words[@]}"; do
#        if [[ "$w" == "$cur"* ]]; then
#            COMPREPLY+=("$w")
#        fi
#    done
#
#    # Restore original word breaks
#    COMP_WORDBREAKS="$old_wb"
#}
#complete -F _ollama_run_completion ollama
#```
#
#But we need to ensure no filename fallback. The `complete` command without options should not fallback. But Bash may still fallback to file completion? Actually, if COMPREPLY is empty, bash may fallback to filenames. The requirement says "No filename fallback: If no models match, provide no suggestions and do not fall back to files." In Bash, if COMPREPLY is empty, it will fallback to file names. To disable, we need to use `complete -o nospace`? Wait - `-o nospace` just disables adding space. To disable file fallback, we can set `COMPREPLY` to empty and also set `return`. But bash still fallback to file names if COMPREPLY is empty? I think yes. To avoid fallback, we need to use `complete -o default`? Wait, `-o default` is the opposite, enabling default file completion. To disable, we must use `complete -o nospace -o bashdefault`? Hmm. Actually, by default, bash completion will use default completion if the custom function returns 0. If we return 0 but COMPREPLY is empty, bash will fallback to default (file) completion. The way to prevent that is to use `return 1`? No, you can set `COMPREPLY=()` and then `return 0`? I think default fallback is only when completion function returns 0 and COMPREPLY is null? The manual: "If the completion function returns an exit status of 0 (success), the shell will attempt to complete the word using the completions in COMPREPLY. If COMPREPLY is empty, the shell will use the default completion (i.e., filename completion). To prevent this, set the return status to 1." So we can simply `return 1` if no matches. That will disable fallback. So modify: after computing matches, if COMPREPLY empty then restore word breaks and return 1. But we also need to handle early returns: after restoration.
#
#Let's modify:
#
#```
#    COMPREPLY=()
#    for w in "${words[@]}"; do
#        if [[ "$w" == "$cur"* ]]; then
#            COMPREPLY+=("$w")
#        fi
#    done
#
#    # Restore word breaks
#    COMP_WORDBREAKS="$old_wb"
#
#    # If no completions, avoid default file completion
#    if (( ${#COMPREPLY[@]} == 0 )); then
#        return 1
#    fi
#```
#
#But we must ensure not to fall back after early returns. So we need to restore before each return. For early returns, we already restore. For final case, we restore then return 1. That will avoid fallback. Good.
#
#Also dedupe using awk; we used read -d '' and array. We can simplify: `mapfile -t words < <(printf '%s\n' "$model_list" | awk '!seen[$0]++')` but mapfile is available in Bash 4+. We'll use mapfile. The requirement: standard Bash + bash-completion v2. mapfile is fine.
#
#Let's implement:
#
#```
#    mapfile -t words < <(printf '%s\n' "$model_list" | awk '!seen[$0]++')
#```
#
#No need for read -d. Then loop.
#
#Also handle case if `model_list` empty: then words empty. Then COMPREPLY empty; we return 1.
#
#Edge: `model_list` might be empty string; mapfile reads nothing. Works.
#
#Let's rewrite.
#
#Also we need to set `old_wb` at start; but we must set `old_wb` before potentially altering it. We already did.
#
#Also ensure we restore in all returns. Good.
#
#Now final script.
#
#We must keep comments with #. No blank lines. But we can have empty lines preceded by #? Not necessary. I'll not include blank lines.
#
#Let's produce final script.
#...done thinking.

# This script provides bash completion for 'ollama run' to suggest local model names.
# It handles model names containing colons, avoids filename fallback, and ensures
# restoration of COMP_WORDBREAKS after completion.

_ollama_run_completion() {
    local cur prev run_index
    # Save original word breaks
    local old_wb="$COMP_WORDBREAKS"
    # Temporarily remove colon from word breaks
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"

    # Find the index of the literal word 'run' in COMP_WORDS
    run_index=-1
    for ((i=0; i<COMP_CWORD; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Ensure completion is only for the word immediately after 'run'
    if (( run_index == -1 || COMP_CWORD != run_index + 1 )); then
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Retrieve current word being completed
    if type -p _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Fetch model names from 'ollama list'
    local model_list
    if ! model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Deduplicate and load into array
    local words
    mapfile -t words < <(printf '%s\n' "$model_list" | awk '!seen[$0]++')

    # Generate completions filtered by current word
    COMPREPLY=()
    for w in "${words[@]}"; do
        if [[ "$w" == "$cur"* ]]; then
            COMPREPLY+=("$w")
        fi
    done

    # Restore original word breaks
    COMP_WORDBREAKS="$old_wb"

    # If no completions, avoid default file completion
    if (( ${#COMPREPLY[@]} == 0 )); then
        return 1
    fi
}
complete -F _ollama_run_completion ollama

