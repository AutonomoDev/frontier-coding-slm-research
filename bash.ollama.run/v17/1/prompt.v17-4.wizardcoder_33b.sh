Here is a basic framework for your script:
```bash
#!/bin/bash

_ollama_completions() {
    # If the command is not 'ollama run', return immediately to avoid interference with other commands
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi
    
    OLD_IFS=$IFS
    
    # Temporarily remove : from COMP_WORDBREAKS and get current word (after colon)
    IFS=' '
    cur=${COMP_LINE##* }
    COMP_WORDS=( $cur )
    unset IFS
    _get_comp_words_by_ref -n : cur prev
    
    # Restore COMP_WORDBREAKS and set completions
    COMPREPLY=()
    if command -v ollama &>/dev/null; then
        models=$(ollama list | awk 'NR > 1 {print $1}')
        COMPREPLY=($(compgen -W "${models}" -- "$cur"))
    fi
    
    IFS=$OLD_IFS
    
    # Call bash-completion helper function to ensure suggestions are displayed correctly after a colon is typed
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
```
Please note that this script assumes you have `bash`, `awk`, `compgen` and `__ltrim_colon_completions` available. Be sure to test it in a controlled environment before using it in your production environment. 

