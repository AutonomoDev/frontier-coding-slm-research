#Thinking...
#We need to produce a bash completion script that provides completions for `ollama run` arguments. Requirements: Only activate when second word is 'run'. We parse output of 'ollama list', get first column, skip header. Provide suggestions matching current word. No filename fallback. Unique suggestions. Use standard bash. Should not use functions from bash-completion that may not exist. Use COMP_WORDS, COMP_CWORD, COMPREPLY.
#
#We'll define a function e.g. _ollama_run() that fills COMPREPLY. We'll check if ${COMP_WORDS[1]} is run. Also ensure we are not completing the command itself. For 'ollama run' only. For example, user could type 'ollama run <TAB>' - then we should propose suggestions.
#
#We need to ensure no fallback to filenames. In bash completion, if we leave COMPREPLY empty, no suggestions. So we can just skip default.
#
#Implementation: use 'ollama list' command. But we might want to cache results to avoid repeated calls? For simplicity, we can just call it each time. But we could implement caching within the script using a variable like _ollama_list_cache. But not required.
#
#Parsing: we can do: models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}').
#
#We also need to avoid duplicates. In case 'ollama list' might contain duplicates? Not typical, but we can use uniq.
#
#We need to filter by current word. So we need to get the word currently being completed. In bash completion, the word being completed is usually at COMP_WORDS[COMP_CWORD]. For a simple command 'ollama run <word>', COMP_CWORD will be 2 (0-indexed). Actually COMP_WORDS[0] = 'ollama', [1] = 'run', [2] = <current word being completed> (maybe empty). So we can use current=${COMP_WORDS[COMP_CWORD]}.
#
#We then produce COMPREPLY=($(compgen -W "$models" -- "$current")). But we should ensure no fallback. compgen by default would fallback to filenames if no matches. We can disable that by specifying -W and using '--' to stop options. However compgen will still try to complete filenames if no matches? Actually 'compgen -W' uses the provided word list; if no matches, it returns nothing. So fine.
#
#Alternatively we could manually filter by prefix.
#
#We need to use 'compopt -o default' etc? Not needed.
#
#Let's produce script:

# Bash completion for ollama run
# Save function
#_ollama_run()
#{
#    # Only act when second word is 'run'
#    if [[ ${COMP_WORDS[1]} != run ]]; then
#        return
#    fi
#
#    # Only complete the third word (model name)
#    local cur=${COMP_WORDS[COMP_CWORD]}
#    local models
#
#    # Retrieve model names
#    models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | sort -u)
#
#    # Build completions
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#    return
#}
#
#complete -F _ollama_run ollama
#```
#
#This is the basic script. But we need to ensure we don't trigger when the user is completing subcommands like 'ollama run ...', not 'ollama <TAB>'? Actually the complete -F _ollama_run ollama will apply to all 'ollama' commands. Inside function we check if second word is run. That's fine.
#
#Edge Cases: When user types 'ollama run ' with trailing space, then COMP_CWORD may be 2? Actually if there is a trailing space, the word being completed might be empty, and COMP_CWORD will be 3? Let's recall: If the cursor is at the end after a space, the last word is an empty string; COMP_CWORD is index of the word to complete. So if typed "ollama run " and press tab, we want to complete model names. In that case, COMP_WORDS[COMP_CWORD] may be empty string. But we check second word is 'run', which is fine. The cur will be empty, compgen will list all models.
#
#Now, ensure we don't produce filename suggestions if no matches. The function will produce COMPREPLY=($(compgen ...)). If no matches, compgen returns nothing, so COMPREPLY will be empty array. Good.
#
#We also need to avoid using advanced bash features not standard. Use 'local' etc. The script uses standard.
#
#We should also avoid using 'compgen -W' with variable that might contain newlines; but that's fine.
#
#Add comments to explain. Provide script. Should not output anything else.
#
#Double-check: 'COMP_WORDS' indexing: [0] command, [1] subcommand, [2] argument. For 'ollama run <TAB>', COMP_CWORD=2. The 'current' is the word being completed. Good.
#
#Edge case: If user types 'ollama run cod<TAB>' but the cursor is after 'cod', then COMP_WORDS[2] will be 'cod', COMP_CWORD=2. Good.
#
#Thus the script works.
#
#We need to mention that we skip header line 'NR>1', so the first line header is skipped.
#
#Potential duplicates: use sort -u.
#
#Add comments.
#
#Return 0 at end.
#
#We need to ensure no other completions happen. We return after adding COMPREPLY. So fine.
#
#Ok. Let's output script.
#...done thinking.

#!/usr/bin/env bash
#
# Bash completion for the "ollama run" command.
#
# This script provides autocompletion suggestions for model names
# after the user types:   ollama run <TAB>
#
# It retrieves the list of local models by invoking "ollama list"
# and parses the first column of the output (skipping the header).
# Only completions for the word immediately following "run" are
# offered, and no filename fallback is performed.
#
# To enable the completion, source this file from your shell:
#   source /path/to/this_script.sh
#
# Note: This script uses only standard Bash constructs and does
#       not depend on the full bash-completion library.

_ollama_run()
{
    # Ensure the completion is only for "ollama run ..."
    # COMP_WORDS[0] = "ollama", COMP_WORDS[1] = subcommand
    if [[ ${COMP_WORDS[1]} != run ]]; then
        return
    fi

    # Word currently being completed (may be empty if cursor is after a space)
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch model names from "ollama list"
    # Skip the header line (NR>1) and keep only the first column.
    # Use sort -u to eliminate any duplicates.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | sort -u)

    # Generate the list of matching completions
    # compgen -W supplies the word list; if no matches, COMPREPLY stays empty.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Attach the completion function to the "ollama" command
complete -F _ollama_run ollama

