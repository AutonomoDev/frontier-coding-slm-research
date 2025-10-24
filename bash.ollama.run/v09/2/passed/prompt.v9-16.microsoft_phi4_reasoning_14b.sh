#<think>We are Phi, output a Bash script code block with all required comments. The task: create robust bash completion for `ollama run` command. Requirements:
#- Create function _ollama_completions that does dynamic completions on model names from "ollama list". Model names have colons which cause issues.
#- Must handle word break splitting in Bash, so need to save COMP_WORDBREAKS, remove colon (i.e., modify it), re-parse command line with `_get_comp_words_by_ref -n : cur prev` to correctly get current/prev words. Then restore original word break characters.
#- Use `ollama list | awk 'NR>1 {print $1}'`.
#- Register completion using complete -F _ollama_completions ollama.
#
#I must include detailed comments inside code as per instructions (but no commentary outside source code). So produce a script in Bash with all needed inline comments. It must be a single contiguous block of code that can be saved to `.sh` file.
#
#I'll produce a script with function `_ollama_completions`. The code structure:
#```
#_ollama_completions() {
#    # Save the original word break characters.
#    local _old_wb=${COMP_WORDBREAKS}
#    # Remove colon from COMP_WORDBREAKS to avoid colon splitting
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#    # Use helper function _get_comp_words_by_ref to re-parse words with colon not considered as break.
#    _get_comp_words_by_ref -n : cur prev
#    # Restore original word breaks immediately.
#    COMP_WORDBREAKS=${_old_wb}
#
#    # Check if the previous token is "run"
#    if [[ "$prev" == "run" ]]; then
#        # Get available models from ollama list, skipping header line (NR>1) and printing first column.
#        local models=$(ollama list | awk 'NR > 1 { print $1 }')
#        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#    fi
#}
#complete -F _ollama_completions ollama
#```
#I'll now check instructions to produce a single contiguous block of code with detailed comments and no extra explanation outside the source code. I must output exactly one block that is the script.
#
#Double-check requirements:
#- Provide robust bash completions for `ollama run`.
#- Use dynamic retrieval from `ollama list` command.
#- Handle models with colon correctly, re-parsing `cur` and `prev`.
#- The code comments inside are allowed as long as they are in source code comments. They must be thorough.
#
#The sample output provided has instructions on what to do in code block: "THE SOLUTION:" then steps.
#
#I need to produce code that is a script that can be saved directly to `.sh` file, so I add a shebang maybe "#!/bin/bash" at the top? But instructions does not require one. However best practice for Bash completion script maybe include #/bin/bash if it's used as executable. But typically completion scripts are sourced, so they might not have a shebang. However including a comment "#!/usr/bin/env bash" is common.
#
#But instructions: "The entire output must be a single, contiguous block of code that could be saved directly to a `.sh` file." So I'll produce a complete script with shebang maybe optional.
#I can include shebang if desired? Possibly yes. But sometimes people do not want that because completion scripts are sourced.
#
#I can simply write function definition and then "complete -F _ollama_completions ollama". Also add extra comments inside code explaining steps.
#
#I'll produce a robust script with detailed inline comments, no other text.
#
#We must produce block with no commentary outside source code comments. So I'll produce final answer as:
#
#```
##!/bin/bash
## Bash completion function for the `ollama run` command.
#_ollama_completions() {
#    # Save original COMP_WORDBREAKS to restore later, because we are modifying it.
#    local _old_wb="${COMP_WORDBREAKS}"
#
#    # Remove colon from word break characters to prevent Bash from splitting words at colon.
#    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
#
#    # Re-parse the command line using helper function, excluding colon as a separator (-n :).
#    _get_comp_words_by_ref -n : cur prev
#
#    # Immediately restore original COMP_WORDBREAKS to avoid side effects on subsequent completions.
#    COMP_WORDBREAKS="${_old_wb}"
#
#    # Proceed only if the previous word is "run", ensuring we complete only model names after 'ollama run'.
#    if [[ "$prev" == "run" ]]; then
#        # Retrieve available models dynamically from `ollama list`, excluding header.
#        local models
#        models=$(ollama list | awk 'NR > 1 { print $1 }')
#
#        # Generate completion matches using compgen, matching against the current word fragment.
#        COMPREPLY=( $(compgen -W "$models" -- "${cur}") )
#    fi
#}
## Register the completion function with bash-completion for the ollama command.
#complete -F _ollama_completions ollama
#```
#
#I must check if code block is correct. I'll also note that our instructions say "Do not add completions for other subcommands or options unless specified" so it's only for `run` subcommand.
#
#Double-check step:
#- The script should dynamically complete model names retrieved from "ollama list". It extracts models with awk 'NR>1 {print $1}'.
#- And use compgen -W "$models" -- "$cur"
#- Use _get_comp_words_by_ref -n : to get the proper current and previous words.
#
#The code is correct. I'll produce final answer as a single contiguous block of code. We'll ensure that it's in a single block. We'll output exactly without extra commentary outside code comments.
#
#I must not include any explanation text outside the source code comments, so I'll only include code with internal comments.
#
#I'll now produce answer accordingly.</think>
#!/bin/bash
# Bash completion function for the `ollama run` command.
_ollama_completions() {
    # Save original word break characters to restore later.
    local _old_wb="${COMP_WORDBREAKS}"
    
    # Remove colon from COMP_WORDBREAKS to prevent bash from splitting words at ':'.
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
    
    # Re-parse the command line using _get_comp_words_by_ref with colon excluded (-n :).
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS immediately to avoid affecting other completions.
    COMP_WORDBREAKS="${_old_wb}"
    
    # Complete model names only if the previous word is "run".
    if [[ "$prev" == "run" ]]; then
        # Dynamically retrieve available models from `ollama list`, skipping header.
        local models
        models=$(ollama list | awk 'NR > 1 { print $1 }')
        
        # Generate completion candidates matching the current word fragment.
        COMPREPLY=( $(compgen -W "$models" -- "${cur}") )
    fi
}
# Register _ollama_completions as the completion function for the ollama command.
complete -F _ollama_completions ollama

