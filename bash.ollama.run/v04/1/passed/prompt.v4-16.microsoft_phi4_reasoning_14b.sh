#<think>We are given a system message instructing to produce Bash completion script for `ollama run` command. The solution is to be self-contained and can be sourced (e.g., source my_script.sh). It must provide autocompletion suggestions for model names when user types "ollama run <TAB>" and then press tab. Requirements are detailed:
#
#Requirements:
#- Use bash-completion v2 framework.
#- Only trigger if second word is exactly "run".
#- Parse output of `ollama list`, skip header line, extract only first column using awk or cut.
#- Filter suggestions based on what user typed after "ollama run ".
#- Do not provide fallback to filenames (i.e. don't fall back to file names).
#- Ensure unique suggestions.
#
#I must produce a complete script with comments explaining steps, no further output. Use proper variables: COMP_WORDS, etc.
#We need to use _init_completion or similar? Actually in bash-completion v2, there is function "_arguments" or "complete", etc. But the instructions say "self-contained Bash completion script that can be sourced". So we want a script that uses "complete -F ..." mechanism.
#
#I'll recall: To provide completions for command-line tools, one typical approach is to define a function with name starting with "_" and then complete using complete -F <function> command. But instructions require that the completions are triggered only if second word exactly equals run. So we need check inside our completion function if "${COMP_WORDS[1]}" equals "run". If not, do nothing.
#
#Plan:
#- Write a bash script for completions.
#- At top: #!/bin/bash maybe optional? But since it's to be sourced, no shebang necessary.
#- Write function _ollama_run_completion() that is our completion handler.
#- In the function, check if second word equals "run". If not then do nothing.
#- Then get what user typed for argument 2 (the model name). Use COMP_WORDS array index 2, because ollama run <model> so arguments are: [0]="ollama", [1]="run", [2]=model.
#- Let user input be ${COMP_WORDS[2]} maybe? But if not provided then it's empty string.
#- Then get list of models by running "ollama list" and filtering lines using awk or cut.
#
#I can do something like:
#models=$(ollama list | awk 'NR>1 {print $1}' | sort -u) perhaps sorting unique.
#But instructions require "the final list of completion suggestions must not contain duplicates", so we need to remove duplicates. But there's no guarantee that `ollama list` output is in sorted order and free from duplicates? So using sort -u is allowed.
#
#Alternatively, we can use awk command "NR>1" to skip header lines.
#But maybe we want to use cut instead of awk: "ollama list | tail -n +2 | cut -d' ' -f1". But if names have spaces? Possibly not, because model names are like "llama3:latest", so no spaces. So using cut is safe.
#
#I can do:
#models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)
#
#But careful: if user typed something that partially matches a model name, then filter by substring match.
#So let prefix=${COMP_WORDS[2]}. Then create suggestions: for each model in models, if it starts with prefix (or matches pattern) then add to an array.
#
#I can use compgen -W option? But instructions say "the completion suggestions MUST be filtered based on word user is currently typing", and must not fallback.
#We can use COMPREPLY array.
#So function _ollama_run_completion:
#   if [ "${COMP_WORDS[1]}" != "run" ]; then
#      return 0 or something maybe just exit.
#   fi
#
#   # Get prefix argument, if empty string, then we want all models.
#   local cur=${COMP_WORDS[2]:-}
#   # But also note: sometimes COMP_CWORD might be used to extract the current word.
#
#Wait check: We need to get the partially typed word. In bash-completion, "cur" is set to ${COMPREPLY} maybe? Actually in completion functions for _arguments style we do:
#   cur=${COMP_WORDS[COMP_CWORD]}
#Because COMP_WORDS is array of command line arguments and COMP_CWORD is index of current argument.
#So then local cur=${COMP_WORDS[COMP_CWORD]}.
#
#Then fetch models from ollama list output, skipping header. Then filter models that start with the prefix (case sensitive).
#We can use something like:
#for model in $(ollama list | awk 'NR>1 {print $1}'); do
#  if [[ "$model" == "$cur"* ]]; then COMPREPLY+=("$model"); fi; done
#
#But to avoid duplicates, we may put suggestions into a variable or array and then remove duplicates. However, if the user types an empty prefix, we want all models.
#But also using "compgen -W" with option might be simpler.
#
#I can do something like:
#models=$(ollama list | awk 'NR>1 {print $1}' | sort -u)
#Then I can do compgen -W "$models" -- "$cur". But then it doesn't require iterating? But if we use compgen -W, then that may include completions for file names? Wait requirement "No Filename Fallback", so using compgen with pattern might automatically list files from directory as well.
#But instructions say: "Do not fall back to suggesting filenames from current directory." Using compgen -W "$models" "$cur" is correct because compgen -W doesn't fallback to file names if provided a word list. But need to check: compgen with the -W flag in bash completion does not do filename completions if you supply words; I think it's safe.
#
#But instructions require "The final list of suggestions MUST NOT contain duplicate entries."
#So using sort -u ensures no duplicates. But also compgen might show duplicates? Actually, we can store unique suggestions by storing them in an array and then output with COMPREPLY.
#Alternatively, a simpler way: Use the builtin compgen command with "-W" option:
#   compgen -W "$(ollama list | awk 'NR>1 {print $1}' | sort -u)" -- "$cur"
#But that may not work because the expansion of the command substitution inside -W might have issues if there is spaces. But model names don't contain spaces? They are like "llama3:latest", so it's safe.
#Wait check: The list of models from `ollama list` output includes colon and digits, but not spaces.
#
#I can do:
#local models
#models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)
#COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
#
#But caution: compgen might output completions that don't match exactly. But we want suggestions that start with prefix.
#compgen uses pattern matching, so if the current typed string is "co" then it will only complete models starting with "co", which is what is required.
#
#I need to check ordering. I need to check that only trigger if second word equals run. So do:
#if [ "${COMP_WORDS[1]}" != "run" ]; then
#   return 0 # no completion.
#fi
#
#Then use COMP_CWORD as index of current argument: local cur=${COMP_WORDS[COMP_CWORD]}.
#But also note, if there is no second argument in words array then maybe it's blank. But that's fine.
#
#I need to check the script for errors and output only complete script with comments.
#
#I'll produce a complete script like:
#
#```
##!/usr/bin/env bash
## ollama run command completion script
#
#_ollama_run_completion() {
#    # Check if we're completing the 'run' subcommand of 'ollama'
#    if [ "${COMP_WORDS[1]}" != "run" ]; then
#        return 0
#    fi
#
#    # Get current word (partial input)
#    local cur=${COMP_WORDS[COMP_CWORD]}
#
#    # Retrieve available model names from `ollama list`, skipping the header line.
#    # We use awk to extract only the first column and sort -u for uniqueness.
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)
#
#    # Generate completions based on the prefix typed by the user.
#    COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
#}
#
#complete -F _ollama_run_completion ollama
#```
#
#I must also include comments that explain what each part does, and ensure it's a complete script.
#
#We should not produce extra output. So I'll produce code with inline comments explaining each line.
#Make sure to check conditions:
#- Only trigger if second word equals run (we check this).
#- Use only model names from first column (using awk 'NR>1' ensures header is skipped, and prints $1).
#- Filter suggestions based on current input prefix: using compgen -W "$models" -- "$cur".
#- Do not fallback to filenames because we are specifying the word list with compgen -W.
#- Ensure unique completions by sorting -u.
#
#Double-check instructions: "You must parse the output of this command." Yes, use `ollama list`.
#I must note that using awk 'NR>1' is allowed. Alternatively, could be done with tail and cut: tail -n +2 ollama list | cut -d' ' -f1 but I choose to use awk.
#"Use standard variables COMP_WORDS etc." Yes.
#
#- "The script should provide autocompletion suggestions for model names when user types `ollama run`".
#
#Edge case: what if the `ollama` command is not found? But that's out-of-scope. But we have 2>/dev/null in our command substitution so that errors won't be printed to stderr.
#
#Double-check potential pitfalls:
#- If there are duplicates in output, using sort -u removes them.
#- The function _ollama_run_completion returns completions if and only if second word equals "run".
#- If user types "ollama run <TAB>" without additional argument? Then cur = empty string. compgen will list all models. That is desired behavior.
#- If user types "ollama run l<TAB>", then cur is 'l', and it filters to those starting with letter 'l'.
#- The function returns completions in COMPREPLY array as expected.
#
#I'll produce a complete script with comments, no markdown formatting output (by default plain text), but instructions say "Output: Only the complete script with comments. Do not include anything else." So I'll produce a code block that is only the script.
#
#I'll now produce final answer.</think>
#!/usr/bin/env bash
# Bash completion script for the 'ollama run' command.
#
# This script provides autocompletion suggestions for model names obtained from:
#   ollama list
#
# It only triggers completions when the second word in the command is exactly "run".
# The available models are parsed from the output of `ollama list` by extracting the first column,
# skipping the header line. Suggestions are filtered based on the user's current input.
#
# Usage: source this script (e.g., "source my_script.sh") and then run:
#   complete -F _ollama_run_completion ollama

_ollama_run_completion() {
    # Only provide completions if the second word is exactly "run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Get the current word (partial input) from COMP_WORDS using COMP_CWORD.
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Retrieve available model names by parsing 'ollama list'.
    # Skip the header line (NR>1) and extract only the first column ($1).
    # The 'sort -u' ensures that duplicate entries are removed.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}' | sort -u)

    # Generate completion suggestions based on the current input prefix.
    # compgen -W with a wordlist will only complete from these model names, avoiding any filename fallbacks.
    COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_run_completion ollama

