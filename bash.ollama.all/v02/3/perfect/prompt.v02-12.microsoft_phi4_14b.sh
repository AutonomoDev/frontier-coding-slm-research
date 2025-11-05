_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    case "${prev}" in
        ollama)
            # Top-level completion for all subcommands
            COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
            return
            ;;
        
        show|run|stop|push|cp|rm)
            # Step A: Extract Word Info
            _get_comp_words_by_ref -n : cur prev

            # Step B: Fetch Models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C: Generate Completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D: Sort and Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        
        create)
            case "${cur}" in
                -*|--*)
                    # Special flag completion for the 'create' command
                    COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
                    return
                    ;;
            esac
            ;;
        
        serve|pull|signin|signout|list|ps|help)
            # No argument completion needed for these commands
            return
            ;;
    esac
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation of Key Parts:
# 
# - **Top-Level Completion:** When the previous word is `ollama`, it provides a list of all subcommands as completions.
#   
# - **Model Name Completion Logic:**
#   - It uses `_get_comp_words_by_ref` to extract current and previous words for context-based completion.
#   - Checks if the `ollama` command exists before proceeding to fetch model names.
#   - Uses `compgen` with a list of models obtained from `ollama list` to generate possible completions.
#   
# - **Special Flag Completion for `create`:** Recognizes flags like `--file`, `-f`, `--quantize`, and `-q`.
# 
# - **No Argument Commands:** Directly returns without further completion actions.
