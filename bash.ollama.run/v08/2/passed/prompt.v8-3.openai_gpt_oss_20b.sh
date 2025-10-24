#Thinking...
#We need to produce a bash completion script for `ollama run` that handles model names with colons. Use bash-completion v2. Must handle colon by modifying COMP_WORDBREAKS. Must detect "run" position. Use _get_comp_words_by_ref if available. Provide fallback. Get model names from `ollama list` ignoring first line, capturing first column, deduplicate.
#
#We should include comments. Ensure script can be sourced. Provide the function name, maybe _ollama_run_complete. Then register with complete.
#
#We need to include handling of COMP_WORDBREAKS correctly: preserve and restore.
#
#Let's craft the script.
#
#We'll write:
#
#```
## Bash completion for `ollama run`
## Handles model names that contain colons (e.g., codellama:13b)
## Compatible with bash-completion v2
#
#_ollama_run_complete() {
#    # Preserve original word breaks
#    local __ol_old_word_breaks="$COMP_WORDBREAKS"
#    # Remove colon so that it is not treated as a word separator
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
#    # Get the words and current index via helper if available
#    local cur prev words cword
#    if _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
#        :
#    else
#        # Manual fallback
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#        words=("${COMP_WORDS[@]}")
#        cword=$COMP_CWORD
#    fi
#
#    # Find the index of "run" in the words array
#    local run_index=-1
#    local i
#    for ((i=0; i<${#words[@]}; i++)); do
#        if [[ "${words[i]}" == "run" ]]; then
#            run_index=$i
#            break
#        fi
#    done
#
#    # Only provide completions when we are immediately after the "run" word
#    if [[ $run_index -eq -1 || $cword -ne $((run_index+1)) ]]; then
#        # No completion, restore word breaks and exit
#        COMP_WORDBREAKS="$__ol_old_word_breaks"
#        return
#    fi
#
#    # Retrieve model names from `ollama list`
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#
#    # Perform completion using compgen
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#
#    # Restore original word breaks
#    COMP_WORDBREAKS="$__ol_old_word_breaks"
#}
#complete -F _ollama_run_complete ollama
#```
#
#But need to avoid -o default, so we don't include -o default. Ensure complete line is "complete -F _ollama_run_complete ollama". That should suffice.
#
#Also note: We should not override COMP_WORDBREAKS before we get words? Because if we modify before we get words, the helper might parse incorrectly. But we use _get_comp_words_by_ref after modifying. That might cause issues. We could preserve original first, then modify, then call helper. But the helper uses COMP_WORDS, which is unaffected by COMP_WORDBREAKS? I think _get_comp_words_by_ref may rely on word breaks. So we need to modify before calling. That's okay.
#
#Also ensure we restore word breaks before any return.
#
#Edge cases: When _get_comp_words_by_ref fails, we fallback. In fallback we didn't use COMP_WORDS? We used it. That's fine.
#
#Also after we restore, we return.
#
#We must ensure we don't clear COMPREPLY when no matches? If compgen produces no matches, COMPREPLY will be empty. That's okay.
#
#We must ensure no default fallback to filenames. By not specifying -o default, we already avoid that.
#
#Also, we need to ensure that we don't inadvertently treat the colon as break before getting words, because we only want to modify after words are parsed? But we need to modify before completion logic that uses compgen. It's fine.
#
#Test with examples.
#
#- $ ollama run<TAB> cur="run", prev=last word before run? Actually, words: ["ollama", "run"]. run_index=1. cword=2? Wait, if we press tab after "run", we are at position 2 (after run). So cword = 2. run_index=1. run_index+1=2. So we pass. cur=""? cur=COMP_WORDS[2] is empty? Actually, when pressing tab, COMP_WORDS[COMP_CWORD] is empty string (since no word typed). Good. compgen will match all models.
#
#- $ ollama run codellama:<TAB> After typing codellama:, cur="codellama:"? Actually, pressing tab after colon, cur="codellama:"? The colon is part of word due to removal of colon from word breaks. Good. compgen matches codellama:13b codellama:34b.
#
#- $ ollama run xyz<TAB> no matches, COMPREPLY empty.
#
#- We must ensure not to provide default file completions. That's fine.
#
#Also need to note that the user might type other arguments after model name? Our completion only triggers when after run. So if they type "ollama run codellama:13b extra", our completion won't run for extra. That's fine.
#
#But the requirement is only to complete model names after "run".
#
#Also we should add a guard: if the command is not exactly "ollama run" but maybe "ollama run --something"? But typical use: `ollama run <model>`.
#
#Edge: if run is not found in words, we bail.
#
#I think script is fine.
#
#We should also set local variables names with leading double underscores? But not necessary.
#
#Also ensure we declare local variables. Use "local" for all.
#
#Also maybe use "local -a models" to store array. But compgen expects string. We'll keep string.
#
#Also ensure we handle whitespace in `ollama list`. The awk command extracts first column. The output might have variable spacing. Using awk 'NR>1 {print $1}' handles that. Then deduplicate with second awk.
#
#Potentially we need to pipe to tr? Not needed.
#
#The script must be ready to source. So we include shebang? It's a script to source, not executed. So no shebang.
#
#Make sure comments start with '#'.
#
#Ok. Let's produce.
#...done thinking.

# Bash completion for `ollama run`
# Handles model names that contain colons (e.g., codellama:13b)
# Compatible with bash‑completion v2
#
# Save the original word‑breaks and temporarily remove ':' so that
# model names are treated as a single word during completion.
# Restore the original settings on every exit path.

_ollama_run_complete() {
    # Preserve the original COMP_WORDBREAKS value
    local __ol_old_word_breaks="$COMP_WORDBREAKS"
    # Remove ':' from word‑breaks so that a name like "codellama:13b"
    # is seen as one word by the completion engine
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Try to use the helper from bash‑completion if available
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
        :
    else
        # Fallback: use the raw COMP_* variables
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Find the position of the word "run" in the command line
    local run_index=-1
    local i
    for ((i=0; i<${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only provide completions when we are immediately after the "run" word
    if [[ $run_index -eq -1 || $cword -ne $((run_index+1)) ]]; then
        COMP_WORDBREAKS="$__ol_old_word_breaks"
        return
    fi

    # Retrieve the list of models, ignoring the header line and deduplicating
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Perform the completion using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore the original word‑breaks before returning
    COMP_WORDBREAKS="$__ol_old_word_breaks"
}

# Register the completion function for the "ollama" command.
# No '-o default' option is used, so filenames will not be suggested.
complete -F _ollama_run_complete ollama

# End of completion script

