#Thinking...
#We need to craft a bash script with comments starting with #. The script must provide completion for ollama run model names. Must follow strict requirements.
#
#Let's draft:
#
##!/usr/bin/env bash
#
## Provide completion for ollama run
#
## function _ollama_run_completion
## register
#
#We must implement logic: find index of literal 'run' in COMP_WORDS. If not found or current word not run_index+1, exit. Use _get_comp_words_by_ref fallback.
#
#Need to temporarily remove colon from COMP_WORDBREAKS.
#
#Get models: local function get_models() that runs 'ollama list' and uses awk 'NR>1 {print $1}'.
#
#Then filter with compgen -W.
#
#Ensure unique suggestions: use associative array.
#
#No default options, no filename fallback. So register: complete -F _ollama_run_completion ollama
#
#Within function, before exit restore COMP_WORDBREAKS.
#
#Also if no models, exit quietly.
#
#Let's write.
#
#We'll use a local variable 'old_comp_wordbreaks'.
#
#Implementation:
#
#_ollama_run_completion() {
#    local old_comp_wordbreaks=$COMP_WORDBREAKS
#    # Remove colon
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#    # Get current and previous words
#    local cur prev
#    # Use _get_comp_words_by_ref if available
#    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
#        _get_comp_words_by_ref -n : cur prev
#    else
#        cur=${COMP_WORDS[COMP_CWORD]}
#        prev=${COMP_WORDS[COMP_CWORD-1]}
#    fi
#
#    # Find index of 'run'
#    local run_idx=-1
#    local i
#    for ((i=0; i<COMP_CWORD; i++)); do
#        if [[ ${COMP_WORDS[i]} == "run" ]]; then
#            run_idx=i
#            break
#        fi
#    done
#
#    # If not found or not at run+1, restore and exit
#    if (( run_idx == -1 || COMP_CWORD != run_idx + 1 )); then
#        COMP_WORDBREAKS=$old_comp_wordbreaks
#        return
#    fi
#
#    # Get model list
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#    if [[ -z $models ]]; then
#        COMP_WORDBREAKS=$old_comp_wordbreaks
#        return
#    fi
#
#    # Build unique list
#    local -a uniq
#    declare -A seen
#    local m
#    while read -r m; do
#        if [[ -z ${seen[$m]} ]]; then
#            uniq+=("$m")
#            seen[$m]=1
#        fi
#    done < <(printf '%s\n' "$models")
#
#    # Filter
#    local suggestions
#    suggestions=$(compgen -W "${uniq[*]}" -- "$cur")
#
#    COMPREPLY=()
#    if [[ -n $suggestions ]]; then
#        COMPREPLY=( $suggestions )
#    fi
#
#    COMP_WORDBREAKS=$old_comp_wordbreaks
#    return
#}
#
#complete -F _ollama_run_completion ollama
#
#But ensure no early returns before restoring. We have multiple returns. Need to guarantee restoration on all paths. We can wrap logic: use local old_comp_wordbreaks; at end we always restore. But if we return early, we must restore. So better to structure with trap or final lines after condition? Let's restructure:
#
#_ollama_run_completion() {
#    local old_comp_wordbreaks=$COMP_WORDBREAKS
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#    local cur prev
#    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
#        _get_comp_words_by_ref -n : cur prev
#    else
#        cur=${COMP_WORDS[COMP_CWORD]}
#        prev=${COMP_WORDS[COMP_CWORD-1]}
#    fi
#
#    local run_idx=-1
#    local i
#    for ((i=0; i<COMP_CWORD; i++)); do
#        if [[ ${COMP_WORDS[i]} == "run" ]]; then
#            run_idx=i
#            break
#        fi
#    done
#
#    if (( run_idx == -1 || COMP_CWORD != run_idx + 1  )); then
#        COMP_WORDBREAKS=$old_comp_wordbreaks
#        return
#    fi
#
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#    if [[ -z $models ]]; then
#        COMP_WORDBREAKS=$old_comp_wordbreaks
#        return
#    fi
#
#    local -A seen
#    local -a uniq
#    local m
#    while read -r m; do
#        if [[ -z ${seen[$m]} ]]; then
#            uniq+=("$m")
#            seen[$m]=1
#        fi
#    done < <(printf '%s\n' "$models")
#
#    local suggestions
#    suggestions=$(compgen -W "${uniq[*]}" -- "$cur")
#
#    COMPREPLY=()
#    if [[ -n $suggestions ]]; then
#        COMPREPLY=( $suggestions )
#    fi
#
#    COMP_WORDBREAKS=$old_comp_wordbreaks
#}
#
#We used -n : in _get_comp_words_by_ref. We also removed colon from COMP_WORDBREAKS to allow completion across colon boundaries.
#
#We also used 'if (( run_idx == -1 || COMP_CWORD != run_idx + 1  ));' Note double spaces maybe issue; but okay.
#
#We have to ensure no -o default. The registration is simple.
#
#Add shebang optional; but script may be sourced. Provide comments with # at each line.
#
#All lines starting with #? Not all lines, only comments. But requirement: "Make sure every line of non-code starts with #". That means comments lines must start with #. Code lines not required to start with #. So okay.
#
#Let's produce final script.
#...done thinking.

#!/usr/bin/env bash
# =====================================================
# Bash completion script for `ollama run` model names
# =====================================================

# Register the completion function for the `ollama` command
complete -F _ollama_run_completion ollama

# ---------------------------------------------
# Completion function
# ---------------------------------------------
_ollama_run_completion() {
    # Preserve the original word break characters
    local old_comp_wordbreaks=$COMP_WORDBREAKS

    # Temporarily remove the colon so it is not treated as a word break
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Retrieve the current and previous words (fallback if _get_comp_words_by_ref is unavailable)
    local cur prev
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Find the index of the literal word "run" in the command line
    local run_idx=-1
    local i
    for ((i=0; i<COMP_CWORD; i++)); do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            run_idx=i
            break
        fi
    done

    # If "run" was not found or we are not completing the word immediately after it,
    # restore word breaks and exit without providing any completions
    if (( run_idx == -1 || COMP_CWORD != run_idx + 1 )); then
        COMP_WORDBREAKS=$old_comp_wordbreaks
        return
    fi

    # Obtain the list of locally available models from `ollama list`
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If the command failed or returned no models, restore and exit
    if [[ -z $models ]]; then
        COMP_WORDBREAKS=$old_comp_wordbreaks
        return
    fi

    # Build a unique, sorted list of model names
    local -A seen
    local -a uniq
    local m
    while read -r m; do
        if [[ -z ${seen[$m]} ]]; then
            uniq+=("$m")
            seen[$m]=1
        fi
    done < <(printf '%s\n' "$models")

    # Generate completions that match the current word prefix
    local suggestions
    suggestions=$(compgen -W "${uniq[*]}" -- "$cur")

    # Populate the completion reply array
    COMPREPLY=()
    if [[ -n $suggestions ]]; then
        COMPREPLY=( $suggestions )
    fi

    # Restore the original word break characters before returning
    COMP_WORDBREAKS=$old_comp_wordbreaks
}

