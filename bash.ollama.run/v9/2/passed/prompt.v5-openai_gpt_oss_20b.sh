#Thinking...
# We need to produce Bash completion script with function _ollama_completions.
# Provide code block only. Must handle model names with colon. Use bash-completion
# v2 function _get_comp_words_by_ref. Must register complete -F. Provide comments.
# Provide only code. Ensure function checks if subcommand is run and if word before
# is run. Implementation:
#
#_ollama_completions() {
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur prev words cword
#}
#```
#
# But need to temporarily modify COMP_WORDBREAKS. Steps: store old, modify, call
# _get_comp_words_by_ref -n :, restore.
#
# Need to consider after restore: maybe still have words variable? Actually
# _get_comp_words_by_ref sets words and cword.
#
# But we also need to use the word list:
# local models=$(ollama list | awk 'NR>1 {print $1}').
#
#We should be careful to handle quoting of models to preserve whitespace? But models don't have whitespace.
#
#We should use COMPREPLY=( $(compgen -W "$models" -- "$cur") ) - but need to quote $cur to preserve.
#
#Also need to handle case when prev == "run". But also check if words[1] == "run"? Actually cur is current word, prev is previous word. So after adjusting, we need to check if prev == "run" to complete model names. However, if user typed "ollama run codellama:" then cur should be empty string? Actually cur would be empty, but we want to complete from model list. That's fine. The previous word is "run" - correct. So if prev == "run" we produce completions.
#
#Edge: if command line has multiple words like "ollama run codellama:13b ..." But we only need to complete the model name after run.
#
#Also might want to handle scenario where "run" is the first argument after "ollama". We may check if words[1] == "run" and cur is last word. But the simple prev == "run" suffices for when user is typing the model. If user typed "ollama run" then cur is empty. We still complete models. Good.
#
#Also need to handle that if there are multiple words after run, we don't provide completions. But not required.
#
#Ok.
#
#Now code.
#
#Also need to include shebang? Not necessary.
#
#Let's produce code:
#
#```
## Bash completion for ollama run, dynamically completing model names
#_ollama_completions() {
#    local cur prev words cword
#    # Preserve original word break characters
#    local _old_wb=${COMP_WORDBREAKS}
#    # Temporarily remove ':' so it is not treated as a separator
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#    # Re-parse the command line, ignoring ':' as a separator
#    _get_comp_words_by_ref -n : cur prev words cword
#    # Restore original word break settings
#    COMP_WORDBREAKS=${_old_wb}
#
#    # Only complete after 'run' subcommand
#    if [[ "$prev" == "run" ]]; then
#        # Extract model names from 'ollama list', skipping header line
#        local models
#        models=$(ollama list | awk 'NR>1 {print $1}')
#        # Generate completion list
#        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#    fi
#}
## Register the completion function for the 'ollama' command
#complete -F _ollama_completions ollama
#```
#
#Need to add comments explaining each step.
#
#Also must use local variables. The script must be contiguous block. Should we use 'local' before 'cur prev words cword'?
#
#Add comments.
#
#We need to mention we need bash-completion v2; _get_comp_words_by_ref is only available in v2. Use that. Provide comment.
#
#Ok produce code.
#...done thinking.

# Bash completion for the `ollama run` command that dynamically completes
# model names, correctly handling names that contain colons (e.g. "codellama:13b").
# This script requires bash-completion v2 or later because it uses the
# helper function `_get_comp_words_by_ref`.

_ollama_completions() {
    local cur prev words cword

    # ----------------------------------------------------------------------
    # 1. Preserve the original set of word‑break characters.
    # ----------------------------------------------------------------------
    local _old_wb=${COMP_WORDBREAKS}

    # ----------------------------------------------------------------------
    # 2. Temporarily remove ':' from the word‑break set so that it is not
    #    treated as a separator by Bash's word parsing logic.
    #    Without this, typing "codellama:" would cause Bash to see
    #    "codellama" as the previous word and an empty current word,
    #    breaking the completion context.
    # ----------------------------------------------------------------------
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # ----------------------------------------------------------------------
    # 3. Re‑parse the command line using the updated word‑break settings.
    #    The `-n :` option tells `_get_comp_words_by_ref` to ignore the
    #    colon as a separator, yielding correct values for `cur`, `prev`,
    #    `words`, and `cword`.
    # ----------------------------------------------------------------------
    _get_comp_words_by_ref -n : cur prev words cword

    # ----------------------------------------------------------------------
    # 4. Restore the original word‑break characters to avoid side‑effects
    #    on other completions or commands.
    # ----------------------------------------------------------------------
    COMP_WORDBREAKS=${_old_wb}

    # ----------------------------------------------------------------------
    # 5. Provide completions only when the previous word is the "run"
    #    subcommand.  This ensures that we complete model names after
    #    `ollama run` and not for other contexts.
    # ----------------------------------------------------------------------
    if [[ "$prev" == "run" ]]; then
        # Dynamically retrieve model names from `ollama list`, skipping the
        # header line (NR>1) and extracting the first column.
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Use `compgen` to generate the list of possible completions for
        # the current word (`$cur`).  The `--` flag indicates that
        # `$cur` is the word to complete.
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completions ollama

