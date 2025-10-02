#Thinking...
#We need to provide a Bash script that can be sourced to provide completions for "ollama run". Should use standard completion functions. Need to use COMP_WORDS, COMP_CWORD. We can use _get_comp_words_by_ref if available, else fallback. Provide function _ollama_run_complete and register with complete -F _ollama_run_complete ollama.
#
#Need to parse ollama list output: skip header line starting with NAME, then cut first column. Use cut -d' ' -f1? But spaces may be multiple; we can use awk. But requirement says use cut. Could do cut -d' ' -f1 but with variable spaces? cut -d' ' might split on single spaces, but if there are multiple spaces, consecutive spaces produce empty fields. The header line "NAME                            ID              SIZE    MODIFIED" has multiple spaces; cut -d' ' -f1 would output "NAME" but there will be empty fields for other spaces. But if we use cut -d' ' -f1 and then grep -v '^NAME$' to skip header, we would get "NAME" then maybe many empty lines? Actually cut -d' ' -f1 will produce "NAME" for header, "llama3:latest" for first model, etc. It won't produce empties because cut uses the delimiter to split. But consecutive delimiters produce empty fields, but we only take first field, so it's fine. So use:
#
#models=$(ollama list | cut -d' ' -f1 | grep -v '^NAME$' | sort -u)
#
#We need to handle colon in names; cut doesn't split on colon. Good.
#
#Need to filter suggestions based on cur (current word). Use case: if [[ $cur == * ]]; we can use compgen -W "$models" -- "$cur" to generate matches. But compgen may generate file fallback if no match. To avoid that, we can use compgen -W "$models" -S '' -- "$cur" maybe? Actually compgen -W will only generate matches; if no matches, COMPREPLY stays empty. But we must ensure no file fallback. Use compgen -W "$models" -- "$cur". compgen will not fallback. Yes. compgen does not fallback to files. Good.
#
#We must ensure no duplicate suggestions: we already used sort -u.
#
#We need to handle case-insensitive? Not needed. Use as is.
#
#Need to ensure _get_comp_words_by_ref fallback: If function exists, call it: `_get_comp_words_by_ref -n : cur prev`? Actually default signature: `_get_comp_words_by_ref cur prev`. We can call: `_get_comp_words_by_ref -n : cur prev`? Wait, _get_comp_words_by_ref takes options: -n removes null, etc. But simplest: if function exists, call `_get_comp_words_by_ref -n : cur prev`? Actually to get words before cursor: _get_comp_words_by_ref -n : cur prev. This returns current word and previous word. We can use: `_get_comp_words_by_ref cur prev`. That gets cur and prev. So we need to check: if type -t _get_comp_words_by_ref >/dev/null 2>&1; then use; else set cur=${COMP_WORDS[COMP_CWORD]}; prev=${COMP_WORDS[COMP_CWORD-1]}.
#
#Also need to check that previous word is exactly 'run' and first word is 'ollama'. Ensure we don't provide completions for other subcommands. So in function, we can early return unless first word is 'ollama' and prev is 'run'.
#
#Return via return 0.
#
#We also must register completion function: `complete -F _ollama_run_complete ollama`.
#
#Also, we might want to set `complete -o nospace -o default`? But not required. The script just needs to provide completions. Use `complete -F _ollama_run_complete ollama`.
#
#Let's write.
#
#Add header comments. Provide usage.
#
#Let's craft script.
#
#Edge Cases:
#
#- If ollama list fails? Could produce empty list. In that case, COMPREPLY empty. It's fine.
#
#- The script should be self-contained.
#
#Implementation:
#
#```bash
##!/usr/bin/env bash
## Bash completion for ollama run command
## Provides model name suggestions based on output of `ollama list`
## Only triggers for the word after `run`
## No fallback to file completions
#
#_ollama_run_complete() {
#    local cur prev words cword
#    # Use bash-completion helper if available
#    if type -t _get_comp_words_by_ref >/dev/null 2>&1; then
#        _get_comp_words_by_ref cur prev
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Trigger only when the previous word is 'run' and the command is 'ollama'
#    if [[ ${COMP_WORDS[0]} != ollama ]] || [[ $prev != run ]]; then
#        return 0
#    fi
#
#    # Retrieve available model names
#    local models
#    models=$(ollama list 2>/dev/null | cut -d' ' -f1 | grep -v '^NAME$' | sort -u)
#
#    # Generate completions based on the current word
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#
#    return 0
#}
#
## Register the completion function for the 'ollama' command
#complete -F _ollama_run_complete ollama
#```
#
#But we need to use `COMP_WORDS` and `COMP_CWORD`. Use local cword? Not needed.
#
#Make sure to use `local` for local variables. `words cword` not used.
#
#Also use `local cur prev` as we did.
#
#Now ensure we use `#` at start of non-code lines. All lines start with #.
#
#Let's produce final script.
#...done thinking.

#!/usr/bin/env bash
# Bash completion for the `ollama run` command.
# Provides model name suggestions based on the output of `ollama list`.
# Triggers only for the word immediately following the `run` subcommand.
# Does not fallback to file completions; duplicates are removed.
# Works with or without the bash-completion helper `_get_comp_words_by_ref`.

_ollama_run_complete() {
    local cur prev

    # Attempt to use the bash-completion helper if available.
    if type -t _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref cur prev
    else
        # Fallback: manually extract the current and previous words.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Activate only when the command is `ollama` and the previous word is exactly `run`.
    if [[ ${COMP_WORDS[0]} != ollama ]] || [[ $prev != run ]]; then
        return 0
    fi

    # Get the list of locally installed models, one per line.
    # Skip the header line and ensure uniqueness.
    local models
    models=$(ollama list 2>/dev/null | cut -d' ' -f1 | grep -v '^NAME$' | sort -u)

    # Generate completions that match the current word; no filename fallback.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    return 0
}

# Register the completion function for the `ollama` command.
complete -F _ollama_run_complete ollama

# End of script.

