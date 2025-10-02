#<think>We are asked to produce a robust and correct Bash completion script for the command "ollama run" with autocompletion suggestions for model names obtained by parsing output of "ollama list". It must meet all strict requirements.
#
#Let's restate requirements in own words:
#
#- Must be self-contained bash script which can be sourced.
#- Activation condition: only trigger when command is "ollama", and the second word is exactly "run".
#- Use ollama list command to get model names. We need to parse output, extract first column ignoring header (line starts with NAME).
#- Filter completions based on what user typed currently (i.e., prefix completion). If none match then no suggestions.
#- No fallback: if nothing matches do not list filenames from current directory.
#- Unique suggestions, i.e. deduplicate duplicates.
#- Use standard bash syntax.
#
#We also see instructions:
#"Use standard variables like COMP_WORDS, COMP_CWORD and COMPREPLY."
#Don't use _get_comp_words_by_ref or other non-standard functions.
#Avoid printing raw output of ollama list.
#
#Also check that the word being completed is "ollama run <TAB>" with second word equals "run". We must ensure not to complete subcommands for other words.
#
#Plan: Write a bash function completion script (named _ollama maybe), and then register it using compdef or complete command. The standard approach in Bash Completion v2 is:
#complete -F _function commandName
#So our file can contain:
#
#_script content:
#
#```
## ollama run completion script
#
#_ollama_run_completion() {
#    # Check if the first word is "ollama" and second is "run"
#    local cur prev words cword
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#    # Check that COMP_CWORD >= 2, and COMP_WORDS[0] equals "ollama", COMP_WORDS[1]== "run".
#    if [[ ${COMP_CWORD} -lt 2 ]] || "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run"; then
#        return
#    fi
#
#    # Get the candidate completions: run 'ollama list' and parse out first column skipping header
#    # We can pipe output to awk or cut. We'll use awk.
#    local models tmp
#    models=$(ollama list | awk '!/^NAME/ {print $1}')
#
#    # Deduplicate suggestions, filter by prefix typed.
#    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#}
#complete -F _ollama_run_completion ollama
#```
#
#We must ensure that the code uses proper bash syntax and uses standard variables. The script is self-contained.
#
#I'll produce a commented version:
#
#- Provide comments for clarity.
#- Use compgen with -W option.
#
#Edge cases: if "ollama list" output might include header line, so we skip header lines using awk '!/^NAME/ {print $1}'.
#
#We then use compgen -W "$models" -- "$cur" to generate completions. That works correctly filtering by prefix.
#
#I'll produce a script that is a single file with the above content.
#
#Let's produce final answer in plain text.
#
#I'll produce answer without markdown formatting, i.e. output as code block. But instructions said: "Output: Only complete script with comments. Do not include anything else." So I'll output exactly one script with inline commentary.
#
#I must include usage of COMP_WORDS[0] equals "ollama" and second word equals "run". Ensure no fallback to listing files if there is no match. That is already achieved because compgen will produce an empty list if prefix doesn't match any candidate, and then COMPREPLY becomes empty.
#
#We must also ensure that the script uses only standard bash syntax. I'll check: "local cur prev" etc are fine.
#
#I must consider possible edge cases:
#- The script should be sourced by user.
#- Must not complete other subcommands.
#
#Thus it's correct.
#
#I will produce final answer as a code block containing the entire script with comments and nothing else.
#
#I'll produce answer in plain text.</think>
#!/usr/bin/env bash
# This is a Bash completion script for "ollama run".
# It provides autocompletion suggestions for model names obtained from "ollama list".

_ollama_run_completion() {
    # Only trigger when the command is exactly "ollama" and the second word is "run"
    local cur prev cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ ${COMP_CWORD} -lt 2 ]] || "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run"; then
        return
    fi

    # Get the list of available models by parsing the output of "ollama list"
    # Skip the header line (which starts with NAME) and extract only the first column.
    local model_list
    model_list=$(ollama list | awk '!/^NAME/ {print $1}')

    # Generate completion suggestions that match the current word being typed.
    COMPREPLY=( $(compgen -W "${model_list}" -- "$cur") )
}

# Register the completion function for "ollama"
complete -F _ollama_run_completion ollama

# End of script.

