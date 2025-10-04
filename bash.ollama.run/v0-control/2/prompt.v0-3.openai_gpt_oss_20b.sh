#!/usr/bin/env bash
#
# Bash completion for `ollama run <model>`
# ----------------------------------------
# Places model names from `ollama list` into the completion list.
# No external dependencies – only standard Bash utilities are used.
#
# To install:
#   1. Save this file as ~/.local/share/bash-completion/completions/ollama
#   2. Make sure your system loads the bash‑completion framework
#      (most distributions do this by default, otherwise add
#      `source /usr/share/bash-completion/bash_completion` to your
#      ~/.bashrc)
#
# If you prefer to source this file directly, add
#   source /path/to/this/file
# to your ~/.bashrc or equivalent.

# Thinking...
# We need to write a bash completion function for 'ollama run <model>' that dynamically lists models by parsing output of 'ollama list'. Need to parse output with no external dependencies, just bash, maybe awk/sed. The 'ollama list' prints header line and each model line. Format: NAME ID SIZE MODIFIED. We need to extract the first column, which might contain whitespace? It seems names contain colon and digits but no spaces. So can parse by field splitting.
# 
# Goal: Provide script for Bash completion. Should register function via complete -F _ollama_run ollama
# 
# The function should use `COMPREPLY` array. Use `compgen` or custom. Should handle errors gracefully.
# 
# We need to parse `ollama list` output. Use command substitution: $(ollama list 2>/dev/null). But may fail; we need to handle errors.
# 
# We can extract names using awk '{print $1}' skipping header (NR>1). That prints names.
# 
# However we should ensure it works even if output is on one line? The spec: "when run with no formatting flags" prints names one per line or separated by whitespace. The sample shows tab separated. So parsing by first column is fine.
# 
# Thus function _ollama_run() should:
# 
# - local IFS=$'\n'
# - local cur=${COMP_WORDS[COMP_CWORD]}
# - local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
# - Use compgen -W "$models" -- "$cur" to generate completions.
# 
# Edge case: no models -> nothing.
# 
# Make script self-contained: includes function and registration.
# 
# Add comment about installation: source script, or install by adding to ~/.bash_completion.d.
# 
# Let's produce final script.
# ...done thinking.

# -------------------------------------------------
# Completion function
# -------------------------------------------------
_ollama_run()
{
    local cur prev words cword
    _init_completion || return  # safe init from bash-completion

    # Only offer completions for the argument after `run`
    if [[ ${words[1]} != "run" ]]; then
        return
    fi

    # Grab the list of model names.  Fail silently if `ollama` is
    # not available or if the command fails.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate completion candidates that match the current word.
    COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
}

# -------------------------------------------------
# Register the completion for the `ollama` command.
# -------------------------------------------------
complete -F _ollama_run ollama
