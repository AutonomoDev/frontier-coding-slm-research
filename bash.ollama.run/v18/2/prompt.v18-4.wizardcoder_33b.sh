Here is the bash completion script for `ollama run`. This script only activates for `ollama run <model>`, handles colons (e.g., `codellama:13b`), parses `ollama list` correctly and completes only model arg.

```bash
_ollama_completions() {
    # 1. Check if command line starts with 'ollama run'.
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && \
        { COMPREPLY=(); return 0; }
    
    # 2. Check if the current word is not 'run'.
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # 3. Parse command line for ':' and set cur/prev appropriately.
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # 4. Parse 'ollama list' to get models.
    local models=()
    if command -v ollama &>/dev/null; then 
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # 5. Sort models before completion to avoid unwanted matches due to parsing.
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # 6. Use compgen for model completions.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    # 7. Trim ':' from colon-completions to insert the correct text.
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# 8. Register '_ollama_completions' for 'ollama run'.
complete -F _ollama_completions ollama
```
Please note that this script assumes that `command -v` and `compgen` are available, and `_get_comp_words_by_ref` and `__ltrim_colon_completions` functions if they exist. If any of these assumptions don't hold true for your system, you might have to modify the script accordingly.
Also note that this script should be sourced (i.e., `source <script-name>`) to take effect and it will not affect bash completions in other shell sessions or after a new terminal is opened. 

