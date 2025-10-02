#Thinking...
#We need to write a bash completion script for 'ollama run', handling model names with colons, etc. Must adhere to bash-completion framework v2. Should include the requirements: restore COMP_WORDBREAKS, find position of run, robust parsing, fallback helper, safe filtering, no filename fallback, register completion. Provide only the complete bash script, with clear comments. Ensure every non-code line starts with '#'. Actually, the requirement: "Ensure every non-code line starts with `#`". That means every line that is not code must start with a hash. So comments start with '#', code lines shouldn't start with '#'. But the script will have lines like `_ollama_run_completions() { ... }`. That is code, so it shouldn't start with '#'. But the instruction "Ensure every non-code line starts with '#'" means any line that is not code must start with '#'. Usually code lines don't start with '#'. So that's fine.
#
#Also we need to register completion: `complete -F _ollama_run_completions ollama`. Not use -o default. Should clear COMPREPLY if no matches.
#
#Let's write script:
#
#- Define function `_ollama_run_completions`.
#- Save old COMP_WORDBREAKS and remove colon.
#- Get reference words: try `_get_comp_words_by_ref`, fallback.
#- Find index of "run" in COMP_WORDS.
#- If current word index equals run_index + 1, proceed; else clear COMPREPLY and return.
#- Get current word to complete: `cur`.
#- Retrieve models list: `ollama list | awk 'NR>1 {print $1}' | awk '!seen[$0]++'`.
#- Use compgen to generate reply: `COMPREPLY=($(compgen -W "$models" -- "$cur"))`.
#- If no matches, COMPREPLY=().
#- Restore COMP_WORDBREAKS.
#- Return 0.
#- End function.
#- Then register: `complete -F _ollama_run_completions ollama`.
#
#Add comments.
#
#We need to be careful to use `return` for early exit, ensuring COMP_WORDBREAKS restored.
#
#Let's implement.
#
#We'll ensure all comments start with '#', no other lines start with '#'.
#
#Let's produce final script.
#...done thinking.

# _ollama_run_completions
# Bash completion for 'ollama run', handling model names that contain colons
# and complying with bash-completion framework v2.

_ollama_run_completions() {
    # Preserve original word breaks, remove colon for correct word parsing
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Attempt to use helper; fallback if not available
    if ! _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Find position of the 'run' subcommand
    local run_index=-1
    local i
    for ((i=0; i<${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Trigger completion only if the cursor is immediately after 'run'
    if [[ $run_index -lt 0 || $cword -ne $((run_index + 1)) ]]; then
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Retrieve the list of models, ignoring duplicate names
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Generate completion replies safely
    COMPREPLY=()
    if [[ -n $cur ]]; then
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi

    # Restore original word breaks before exiting
    COMP_WORDBREAKS="$old_wb"
    return
}

# Register the completion function for the 'ollama' command without filename fallback
complete -F _ollama_run_completions ollama
