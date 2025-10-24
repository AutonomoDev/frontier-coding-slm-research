#<think>We need to produce a robust Bash completion script for the command `ollama run` and handle that completions model names come from `ollama list` (which outputs lines with colons). We need to check that our code snippet is in one contiguous block, with comments. The instructions "ABSOLUTELY NO COMMENTARY OR EXPLANATORY TEXT outside of the source code comments themselves" means we must not have any commentary outside code block. But our code block should contain inline comments inside as per specification.
#
#The solution: produce a single script that defines _ollama_completions function for ollama command. It should register completions with complete -F _ollama_completions ollama, and only support completion when the previous word is run. Use temporary removal of colon from COMP_WORDBREAKS. Use _get_comp_words_by_ref if available; check if it exists. Then use "compgen -W" to generate completions from models retrieved with ollama list | awk 'NR>1 {print $1}'.
#
#The instructions: "Focus solely on completing model names after ollama run; do not add completions for other subcommands or options unless specified." So our function must be robust and only complete when previous word is run. And we check if there is a colon in the completion.
#
#We need to produce code with detailed comments explaining why this pattern is necessary (the default tokenization problem) and what each step does.
#
#The code must be one contiguous block of code, not any extra commentary outside. Use inline comments starting with #.
#
#Now I'll produce a Bash script that uses shebang maybe? But instructions: "Your entire output must be a single, contiguous block of code that could be saved directly to a .sh file." So we can write the script in a single block with shebang line "#!/bin/bash" and then function definition. It is not explicitly required to have shebang but it's common.
#
#We also need dynamic completion based on "ollama list" output so we use a command substitution: local models=$(ollama list | awk 'NR>1 {print $1}').
#
#Then, if the previous argument equals "run", then complete. Else do nothing.
#
#Also the code must check if _get_comp_words_by_ref exists and then call it to re-parse words after modifying COMP_WORDBREAKS.
#
#The instructions require: "Use _get_comp_words_by_ref -n : cur prev" with explanation comments.
#
#I'll produce code snippet:
#
#```
##!/bin/bash
## robust bash completion for ollama run command handling colons in model names
#
#_ollama_completions() {
#    # Save original word break characters so we can restore them later.
#    local _old_wb=${COMP_WORDBREAKS}
#    # Remove colon from COMP_WORDBREAKS to prevent Bash from splitting on ':'.
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#    # Re-parse the command line arguments using _get_comp_words_by_ref helper
#    # with -n : option so that colon is not considered a word break during parsing.
#    if type _get_comp_words_by_ref >/dev/null 2>&1; then
#        _get_comp_words_by_ref -n : cur prev
#    else
#        # Fallback: use default behavior if helper isn't available.
#        local cur=${COMP_WORDS[COMP_CWORD]}
#        local prev=${COMP_WORDS[COMP_CWORD-1]:-}
#    fi
#    # Restore original word break characters to avoid side-effects.
#    COMP_WORDBREAKS=${_old_wb}
#
#    # If previous argument is "run", complete with model names retrieved dynamically.
#    if [[ "$prev" == "run" ]]; then
#        # Retrieve available models from 'ollama list' command output, skipping header line.
#        local models
#        models=$(ollama list | awk 'NR>1 {print $1}')
#        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#    fi
#}
#
## Register completion function for the ollama command (only for run subcommand)
#complete -F _ollama_completions ollama
#```
#
#We must produce a single block. I'll produce final code.
#
#I'll produce exactly code block in one contiguous file with no extra commentary outside code comments in the file.
#
#I'll produce output now.</think>
#!/bin/bash
# Robust Bash completion for "ollama run" subcommand handling model names with colons.
_ollama_completions() {
    # Save original word break characters to restore later.
    local _old_wb=${COMP_WORDBREAKS}
    # Remove colon from COMP_WORDBREAKS so that ':' is not treated as a separator.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # Re-parse the command line using _get_comp_words_by_ref if available;
    # the -n : option prevents ':' from being used as a word break during parsing.
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Fallback: use default behavior if helper is not available.
        local cur=${COMP_WORDS[COMP_CWORD]}
        local prev=${COMP_WORDS[COMP_CWORD-1]:-}
    fi
    # Restore original word break characters to avoid affecting subsequent completions.
    COMP_WORDBREAKS=${_old_wb}

    # Only complete model names when the previous argument is "run".
    if [[ "$prev" == "run" ]]; then
        # Dynamically retrieve available models from 'ollama list', skipping the header line.
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register completion for the "ollama" command.
complete -F _ollama_completions ollama

