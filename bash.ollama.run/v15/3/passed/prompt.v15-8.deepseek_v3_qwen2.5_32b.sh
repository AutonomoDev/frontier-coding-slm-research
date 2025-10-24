# Bash completion for 'ollama run' command

_ollama_run_completions() {
    local cur prev words cword opts base comp_words comp_prev
    COMPREPLY=()

    # Preserve original COMP_WORDBREAKS to handle colons in model names properly
    local orig_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Re-parse current and previous words with modified COMP_WORDBREAKS
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS after parsing
    COMP_WORDBREAKS="$orig_wordbreaks"
    
    case "$prev" in
        run)
            if [[ "${COMP_WORDS[1]}" == "run" ]]; then
                # Fetch available models from 'ollama list'
                local models=$(ollama list | awk 'NR>1 {print $1}')
                
                # Generate completions using compgen
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            fi
            ;;
    esac
}

complete -F _ollama_run_completions ollama
