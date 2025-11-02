#!/usr/bin/env bash

# [[HUMAN COMMENTED-OUT]]
#Thinking...
#We need to output a bash-completion script for 'ollama run <model>' that uses 'ollama list' to fetch models. We'll parse output by read -a array? but need to handle lines and whitespace. Use mapfile? It's available in bash 4+. We'll keep POSIX-ish: use while read -r line; do ... ; done < <(ollama list 2>/dev/null). But we need to collect all tokens. Since output could be model names one per line or separated by whitespace. So we can read all tokens via read -r -a models <<< "$(ollama list 2>/dev/null)". This splits on IFS whitespace, capturing tokens. But if lines contain spaces inside names? Unlikely. We'll just assume simple names.
#
#Then we need to produce completions: we need to check if COMP_CWORD==2? For 'ollama run' second word is the model. If COMP_CWORD==2, we provide completions. Use prefix=${COMP_WORDS[COMP_CWORD]}. Then iterate over models and add those starting with prefix to COMPREPLY.
#
#Also handle if model name includes hyphen etc. Use [[ $model == $prefix* ]].
#
#If ollama list fails, we silently exit: no completions.
#
#Also we need to support completion for partial prefix of first word? Actually 'ollama run <Tab>' will trigger when user typed 'ollama run ' and tab, so COMP_CWORD will be 2, prefix empty string. Should suggest all models. That's fine.
#
#We should also handle scenario if user typed 'ollama run --something', but not necessary.
#
#Need to guard against multiple completions? We'll just compute.
#
#Implementation:
#
#_ollama_run() {
#    local cur prev opts
#    COMPREPLY=()
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#    # only complete after 'ollama run'
#    if [[ ${COMP_WORDS[0]} != ollama ]] && [[ ${COMP_WORDS[1]} != run ]]; then
#        return 0
#    fi
#    # only when second argument
#    if [[ $COMP_CWORD -eq 2 ]]; then
#        local models=()
#        # capture output
#        mapfile -t models < <(ollama list 2>/dev/null) || return 0
#        for m in "${models[@]}"; do
#            if [[ $m == $cur* ]]; then
#                COMPREPLY+=("$m")
#            fi
#        done
#    fi
#    return 0
#}
#
#Then register with complete -F _ollama_run ollama.
#
#We need to include installation instructions: drop script to /etc/bash_completion.d/ollama or source from ~/.bash_completion. For activation, use source or reload shell.
#
#Provide minimal script with comments.
#
#Let's produce final answer.
#...done thinking.

# ------------------------------------------------------------
# Bash completion for:  ollama run <model>
# ------------------------------------------------------------
# Place this file in a directory that is sourced by bash completion,
# e.g. /etc/bash_completion.d/ollama or ~/.bash_completion.
# Then reload the shell or run: source <file>
# ------------------------------------------------------------

_ollama_run() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Only offer completions for the second argument of `ollama run`
    if [[ "${COMP_WORDS[0]}" != ollama ]] || [[ "${COMP_WORDS[1]}" != run ]]; then
        return 0
    fi

    # Gather available models; silently ignore any errors
    local models=()
    mapfile -t models < <(ollama list 2>/dev/null) || return 0

    # Filter by the current prefix
    for m in "${models[@]}"; do
        [[ $m == $cur* ]] && COMPREPLY+=("$m")
    done
    return 0
}

# Register the completion function
complete -F _ollama_run ollama
