# [[HUMAN COMMENTED-OUT]]
# Bash Completion for `ollama run`
# =================================
# 
# The following script provides bash completion for the `ollama run` command. It is designed to work with the output of the `ollama list` command, and will suggest valid model names based on the input provided by the user.

_ollama_completions() {
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    local cur prev models=()
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Explanation
# -----------
# 
# 1. The script defines a function called `_ollama_completions`, which is registered as the completion handler for `ollama` using the `complete` command.
# 2. The first line checks that we are in the right context (i.e., the user has typed `ollama run`) and sets the `COMPREPLY` variable to an empty array if not.
# 3. The second line checks that we are completing the second word of the command, which is the model name. If it's not, we return early with a status code of 0 (success).
# 4. We then define local variables `cur`, `prev`, and `models`, which will be used later in the script.
# 5. The next block checks if the `_get_comp_words_by_ref` function is available, which is provided by bash version 4.3 or newer. If it's not available, we fall back to using `COMP_WORDS[COMP_CWORD]` and `COMP_WORDS[COMP_CWORD-1]`.
# 6. We then use the `ollama list` command to get a list of all available models. The output is piped through `tail -n +2` to skip the header, and then `awk '{print $1}'` to extract just the model names.
# 7. If any models were found, we sort them using the `sort` command.
# 8. We use the `compgen` command to generate a list of completion candidates based on the current input (`$cur`). The `-W` flag tells `compgen` to read from the `models` array, and the `--` flag tells it to treat the input as a fixed string rather than a pattern.
# 9. Finally, we use the `__ltrim_colon_completions` function (if available) to trim any colons from the beginning of the completion candidates. This is necessary because `compgen` doesn't handle colons properly.
# 
# Tasks
# -----
# 
# 1. Write a script that provides bash completion for the `ollama run` command.
# 2. The script should suggest valid model names based on the output of the `ollama list` command.
# 3. The script should handle colons (e.g., `codellama:13b`) correctly, including trimming any leading colons from completion candidates.
# 4. The script should also handle edge cases such as no ollama command being available or no models being found.
