#<think>We are asked to produce a self-contained Bash completion script for command "ollama run", such that it provides autocompletion suggestions only for model names based on `ollama list` output (the first column). The script must be robust, using only bash builtins and coreutils, not awk. But the instructions say: "Use only Bash built-ins and GNU coreutils (sort, etc)" but explicitly "Awk is prohibited", so we can't use it. But how to parse "ollama list" output? We need to filter header line that starts with NAME. So what do we want? Possibly using grep or sed. But caution: Use only standard bash built-ins and GNU coreutils (sort, etc). But also the instructions say not to assume non-standard helpers are available. Awk is prohibited so maybe use `sed` or `grep` but these are core utilities. But if they are available as they are in Linux. The output "ollama list" we need to filter out lines that start with NAME and then take first column using e.g., cut.
#
#But note: We must not include any non code text except comments that begin with "#". So every line of non-code starts with #, which means all comment lines should be preceded by a '#' symbol. But "non code" lines refer to instructions? Actually check the requirement: "MAKE SURE EVERY LINE of non-code STARTS WITH #." Means we must ensure that any commentary lines (lines not part of code) are commented out.
#
#Let's see: We need to produce a complete bash completion script that meets all these requirements. Let's think carefully:
#
#We want to implement a function maybe _ollama_run_completion or similar. And then register it with the `complete` command for "ollama run".
#
#The main logic: When we call the completion, check if COMP_WORDS[1] is exactly "run". If not, return.
#
#But careful: The prompt says "only complete suggestions when the second word is exactly 'run'"? Actually requirement states: "targeted triggering: check that the second word (COMP_WORDS[1]) equals run."
#
#So our function should start with:
#
#if [[ ${COMP_CWORD} -le 2 ]] then maybe no completions; but careful: if the command line has only two words, then we have to complete the model name. But what if there are more than two words? Possibly we want to match pattern for autocompletion suggestions.
#
#But the instructions state: "the script must provide autocompletion suggestions for model names when a user types `ollama run` and presses tab". So the subcommand is only after "run" argument (third word, index 2) if provided. But wait: The requirement says that the completion logic MUST only activate for the word immediately following the run subcommand, i.e. COMP_WORDS[2]. Let's re-read the instructions.
#
#It says: "The script must provide autocompletion suggestions for model names when a user types `ollama run ` and presses `<TAB>`." So if you type "ollama run", then the next word to complete is the one after "run" (which would be at index 2). But note that in bash completion, COMP_WORDS[0] is the command itself ("ollama"), COMP_WORDS[1] is the subcommand ("run"). And then COMP_WORDS[2] is the argument we want to complete. So our script should check if COMP_WORDS[1]=="run" and maybe if there are at least 3 words? But careful: If user typed "ollama run " with a trailing space, COMP_CWORD will be one after that; but how many words in COMP_WORDS?
#
#Let's consider: When the cursor is after the model name argument field (or possibly before it), then COMP_WORDS might have more than two elements. So we check if ${COMP_WORDS[1]} equals "run". If not, do nothing.
#
#Then we want to generate suggestions by parsing "ollama list".
#
#But also note that the command "ollama list" is run at the time of completion, so our script will call `ollama list` and parse its output. But if "ollama list" outputs a header, then skip that header line. Also the first column must be extracted.
#
#Plan: We'll store the output of "ollama list" into an array variable by reading it line by line, filtering out lines starting with NAME using grep or sed? But caution: We cannot use awk. We can use sed to remove the header and then cut the field?
#
#We could do something like: suggestions=$(ollama list | sed '1d' | cut -f 1). That would produce output of model names, one per line. And then we want to filter these suggestions with the current word fragment that user typed.
#
#To get the current token being completed (the partial input), in bash completion scripts, you can use: cur=${COMP_WORDS[COMP_CWORD]}. But be careful if _get_comp_words_by_ref is not available, then we need a fallback. So code like:
#if declare -F _get_comp_words_by_ref > /dev/null; then
#   _get_comp_words_by_ref CUR PREV
#else
#   cur=${COMP_WORDS[COMP_CWORD]}
#fi
#
#Then use the filtering: For each suggestion in the list, if it starts with "$cur", append to COMPREPLY array.
#
#But also requirement "Unique suggestions" - so we must ensure no duplicates. But since our parsed output from ollama list is unique if the header is skipped? But maybe duplicate lines might appear? We can sort them and then uniq them. But sorting might require using sort command, which is allowed because coreutils are available.
#
#So plan: do something like:
#models=$(ollama list | sed '1d' | cut -f 1)
#Then remove duplicates by doing "printf '%s\n' "$models" | sort -u" but that might include spaces. But model names are strings with colon in them, so sorting is fine.
#
#But wait: We must not use awk. The instructions mention "Use a standard and reliable tool like cut or sort" so we can use sed and cut? It says: * Use a standard and reliable tool like awk '{print $1}' or cut for this parsing.
#But then later it says "Awk is prohibited". So we choose cut.
#
#So we'll do: models=$(ollama list | sed '1d' | cut -f 1) to get a multi-line string. But we have to filter them one by one maybe using while IFS= read line; do ... done.
#
#I want to use something like:
#COMPREPLY=( $(compgen -W "$models" -- "$cur") ) maybe? But careful: The requirement "Contextual Filtering" means only suggestions that match the current token are allowed. But compgen does exactly that filtering if we pass a list with spaces. But then also "No filename fallback" meaning not to use -o filenames option.
#
#But wait, check the instruction: "If the word being completed does not match any available model, you MUST NOT fall back to suggesting filenames from the current directory." That means that compgen's default behavior is to include file names if no matches? But we want only our suggestions. So we should probably use compgen -W "$models" -- "$cur" without the fallback option.
#
#But note: If we do something like:
#COMPREPLY=( $(compgen -W "${model_list}" -- "${cur}") )
#Then if there is no match, compgen returns empty string, and so COMPREPLY is an array with one element containing empty string? Let me check. Actually compgen produces a list of completions separated by newline, but then the command substitution $(compgen -W "$list" -- "$cur") will result in a whitespace separated set of words if any match are found, or nothing if no match.
#
#But then we want to filter duplicates manually? But if our model_list is already unique, that's fine. However if there might be duplicate lines output from "ollama list"? The instructions say final suggestions MUST NOT contain duplicate entries. So maybe use sort -u on the output string from ollama list.
#
#Plan:
#- Create a local variable models by doing: local models="$(ollama list | sed '1d' | cut -f 1)"; then remove duplicates with something like sorted=$(printf '%s\n' "$models" | sort -u). But then use compgen filtering on the user input token.
#
#Alternatively, we can do:
#COMPREPLY=( $(compgen -W "$(printf '%s\n' "$models" | sort -u)" -- "${cur}") )
#
#That seems like a simple approach. And if no matches are found, COMPREPLY will be empty.
#
#We must check that COMP_WORDS[1] equals "run", else do nothing.
#
#Also, the script should handle _get_comp_words_by_ref fallback for cur and prev if not available.
#
#Thus code:
#
#function _ollama_run_completion() {
#    # Check if we have at least 3 words in command (ollama run <model>)
#    local -a COMPREPLY
#    if [[ ${COMP_CWORD} -le 2 ]]; then
#         return 0
#    fi
#
#    # Ensure subcommand is "run"
#    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#        return 0
#    fi
#
#    # Get current token being completed:
#    local cur prev
#    if declare -F _get_comp_words_by_ref > /dev/null; then
#         _get_comp_words_by_ref cur prev
#    else
#         cur=${COMP_WORDS[COMP_CWORD]}
#    fi
#
#    # Build model list from ollama list output
#    # Parse the first column (model names) skipping header line.
#    local models
#    models=$(ollama list | sed '1d' | cut -f 1)
#
#    # Remove duplicate entries:
#    local sorted_models
#    sorted_models=$(printf '%s\n' "$models" | sort -u)
#
#    COMPREPLY=( $(compgen -W "${sorted_models}" -- "$cur") )
#}
#
#Then register the completion with complete command, like:
#complete -F _ollama_run_completion ollama
#
#But then we need to check: It says "the script must provide autocompletion suggestions for model names when a user types `ollama run`", so maybe if COMP_WORDS[1] is not "run", then do nothing.
#
#But wait, what about the case where there are additional words? The instructions say only complete for model names after "run" subcommand. But what if more than 2 words are typed before? E.g., ollama run foo bar; then maybe completions should be disabled because the field is not in that position (because the next word to be completed might be a parameter for the run command, but we assume only one optional argument, i.e. the model name)? The instructions do not mention additional arguments after the model name.
#
#Maybe we want our function to complete if COMP_WORDS[1] equals "run" and we are in position 2 (the model field). But what if there are more than two words? Then maybe check if COMP_CWORD is exactly 3, meaning the current word is third word. If user typed more arguments after that, then completions might not be needed.
#
#The instructions say: "targeted triggering for the word immediately following run". So only when COMP_WORDS[2] is incomplete. But it's ambiguous what to do if there are additional words after that argument? Possibly we want no completion because we assume the model name is only one argument and then command stops.
#
#I think the simplest: if COMP_CWORD equals 3, then complete suggestions for model names. Otherwise, if more than three words, then ignore completions. But wait, what if user typed "ollama run cod" (three words)? Then COMP_WORDS[0]="ollama", [1]="run", [2]="cod", and COMP_CWORD=3. So we want to complete suggestions for the model name.
#
#But instructions said: "if user types `ollama run xyz` then no suggestion because not starting with any of models" so it's fine if completions array is empty.
#
#I think I'll check if ${#COMP_WORDS[@]} -gt 2, but that doesn't matter. Actually, we want to complete only the model argument which is after "run", and ignore extra words? But what if user types additional words not relevant to this completion stage? The typical approach in Bash completions: COMP_CWORD indicates position of current word. So check that COMP_WORDS[1] equals "run". If so, then we want to provide completions for the model name argument. It's possible that there are more than 3 words (like flags). But then they are not part of the autocompletion suggestions.
#
#I think we want only to complete the model name if it is in position 2 (and maybe ignore others) because the instructions say "the word immediately following run". So probably check: if [[ ${COMP_CWORD} -eq 3 ]]; then do completions; else return. But what if user typed something and then hits tab, then COMP_CWORD might be 2? But when typing, after finishing input of model name, sometimes the cursor is at end of command line and COMP_WORDS array includes an empty trailing element if there's a space.
#
#For example:
#User types "ollama run cod" with no completion. Then COMP_WORDS might have:
#0: ollama
#1: run
#2: cod
#3: "" (if typed a space after the argument)
#Then COMP_CWORD equals 3 maybe? So we want to complete if COMP_WORDS[1]=="run". But then which position is being completed? Usually, you'll check if ${COMP_WORDS[1]} == "run" and not if ${COMP_WORDS[2]} is empty or not. In any case, the simplest approach: check subcommand equals run.
#
#But what if there are extra arguments after model name? Then COMP_CWORD would be greater than 3 (if user types a flag) and maybe we don't want to complete suggestions because they might be mistaken for parameters passed to the model command rather than the model itself. But not sure.
#
#I think it's safest: only provide completions if COMP_WORDS[1] equals "run" AND COMP_CWORD equals 3 OR COMP_CWORD equals 2? Let me re-read instruction: "for model names when a user types `ollama run`". So maybe we want to complete the field that comes after "run", regardless of how many extra words are typed later. But compgen is context-aware in the sense it only completes for the current word (the empty string). So I'll just let it be: if subcommand equals "run" then provide completions.
#
#However, this might lead to completion suggestions even when user is typing flags after the model name? Possibly we can check if COMP_CWORD equals 3 (i.e. only two words before and one word for the current argument) OR maybe we want completions in any case because compgen will compare the prefix with $cur.
#
#But then consider: "ollama run cod" where the model argument is being typed, so COMP_WORDS[2]="cod", COMP_CWORD=3. That works.
#Now if user types "ollama run cod -a", then COMP_WORDS might be:
#0: ollama
#1: run
#2: cod
#3: "-a"
#and current word (COMP_WORDS[3]) is "-a". But then our script would still provide completions for the model list, which may not be appropriate. So maybe we want to restrict completions only if COMP_CWORD equals 3? Because that means exactly one argument after run.
#
#I think so: check if ${#COMP_WORDS[@]} -eq 3 OR if COMP_WORDS[1]=="run" and COMP_CWORD==2 or 3? Let's simulate:
#When user has typed "ollama run cod", how many words? Possibly 3 words ("cod") is the model name, but sometimes there's a trailing empty word at end. So count of COMP_WORDS might be 4 if a space was typed after the argument.
#
#I recall that when using compgen with a -W list, it completes only for the current word. But maybe we want to restrict completions only when there are exactly two or three words, i.e., only complete if the model field is the one being completed.
#
#We can check: if [[ ${COMP_WORDS[1]} == "run" && ($COMP_CWORD -eq 2 || $COMP_CWORD -eq 3) ]]; then provide completions else return 0.
#
#I worry about cases when user types a trailing space. When there's a trailing space, COMP_WORDS array might have an empty element at the end (the current incomplete token). So maybe it will be 4 words with the last one empty. But then COMP_CWORD equals 4, which is not equal to 2 or 3. However, in Bash completions, the current word can be a trailing space. In such cases, $cur might be empty string and compgen -W "$list" -- "" would match all entries. That might be acceptable.
#
#I think it's simpler: if subcommand equals "run", then complete suggestions for model names regardless of COMP_CWORD position (the completion system will only consider the current word). But we don't want to provide completions when a flag is typed after the model name? I can check if COMP_WORDS[2] is provided and not empty, then maybe do nothing. Alternatively, check if COMP_WORDS[1]=="run" AND ((${#COMP_WORDS[@]} <= 3)).
#
#Maybe:
#if [[ "${COMP_WORDS[1]}" == "run" ]]; then
#   # If there are more than 3 words (i.e., additional arguments after model name), ignore completion.
#   if (( ${#COMP_WORDS[@]} > 3 )); then return 0; fi
#   ... complete ...
#fi
#
#But what if user typed exactly two words? That would be "ollama run", and then there is no model argument yet, so we want to offer completions for the model names maybe. But instructions: "when a user types `ollama run`" I think they mean that after typing "run", the completion of model names should appear. So if COMP_WORDS[0]="ollama", [1]="run", then the current word is empty and COMP_CWORD=2 (or 3 if there's trailing space), so it's acceptable.
#
#I can check: if ${#COMP_WORDS[@]} -lt 3, i.e., less than three words means we haven't provided model argument. But then the current token might be empty string? For instance, "ollama run " yields COMP_WORDS[2] as an empty element if a space was typed.
#
#I can do: local word="${COMP_WORDS[2]:-${cur}}" which might not work well.
#
#Alternatively, I'll check:
#if [[ "${COMP_WORDS[1]}" != "run" ]]; then return 0; fi
## Now complete suggestions using compgen based on $cur.
#This will complete the current token regardless of position. But that means if user types "ollama run cod -a", then when they hit tab after "-a", our function would provide completions, which is not desired because model names are only expected for the second argument.
#
#Maybe check: if ${#COMP_WORDS[@]} -gt 3, then return 0.
#Because normally, the command should be "ollama run [model]" and nothing else.
#I think that's what we want.
#
#So I'll do:
#if [[ "${COMP_WORDS[1]}" == "run" && ${#COMP_WORDS[@]} -le 3 ]]; then ... else return 0; fi
#
#That means if there are more than three words in COMP_WORDS, we assume the user is entering additional flags and not asking for model name completion.
#
#But what if there is a trailing space? Then COMP_WORDS might have an extra empty word. So ${#COMP_WORDS[@]} might be 4 even though effectively it's "ollama run cod".
#We can check: if [[ "${COMP_WORDS[2]:-${cur}}" == "" ]] maybe? Not sure.
#
#Maybe simpler: Check the number of arguments in COMP_WORDS minus trailing empty words. We can remove trailing empties by something like:
#local arg_count=0
#for word in "${COMP_WORDS[@]}"; do
#  if [ -n "$word" ]; then ((arg_count++)); fi
#done
#
#Then if arg_count > 2, then no completion.
#I'll do that.
#
#Plan:
#
#function _ollama_run_completion() {
#   local cur prev
#   if declare -F _get_comp_words_by_ref > /dev/null; then
#       _get_comp_words_by_ref cur prev
#   else
#       cur=${COMP_WORDS[COMP_CWORD]}
#   fi
#
#   # Check subcommand is "run" and count non-empty words in COMP_WORDS.
#   local arg_count=0
#   for word in "${COMP_WORDS[@]}"; do
#     if [ -n "$word" ]; then ((arg_count++)); fi
#   done
#
#   if [[ "${COMP_WORDS[1]}" != "run" ]] || [ "$arg_count" -gt 2 ]; then
#       return 0
#   fi
#
#   # Parse model list from ollama list output:
#   local models
#   models=$(ollama list | sed '1d' | cut -f 1)
#
#   # Remove duplicates
#   local sorted_models
#   sorted_models=$(printf '%s\n' "$models" | sort -u)
#
#   COMPREPLY=( $(compgen -W "${sorted_models}" -- "$cur") )
#}
#
#And then register: complete -F _ollama_run_completion ollama
#
#That should meet the requirements.
#
#I'll include a shebang maybe, but it's a completion script so probably not required. But might be used as source command in .bashrc or something.
#
#I must follow instructions exactly with code. I should output plain text code block containing the completion function and registration line.
#
#I'll now produce the final answer accordingly in plain text. We'll include proper comments for clarity.
#Let's check instructions: "Write a Bash completion script that provides completions of model names based on the current token from ollama list", etc.
#
#I must provide a code snippet that is self-contained and uses sed, cut, sort -u as described.
#
#Now I'll produce final answer.</think>

# [[HUMAN COMMENTED-OUT]]
#Below is one complete solution. In this example the function first checks that the subcommand is “run” (and that only two non‐empty words have been given so far), then it calls “ollama list”, skips the header with sed, extracts the first field from each line using cut, removes any duplicate entries via sort –u, and finally uses compgen to filter on the current token. You can source this script (for example in your .bashrc) to enable completions for “ollama run …”
#
#------------------------------------------------------------

#!/bin/bash
# This completion function provides model name completions when using:
#    ollama run [MODEL] ...
#
# It uses "ollama list" to get the available models, skips the header,
# extracts only the first column from each line, removes duplicates,
# and then completes based on the current token.
_ollama_run_completion() {
    # Get the current completion word
    local cur prev
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi

    # Count non-empty words in COMP_WORDS (so that extra flags after the model aren’t completed)
    local arg_count=0
    for word in "${COMP_WORDS[@]}"; do
        if [ -n "$word" ]; then 
            ((arg_count++))
        fi
    done

    # Only provide completions if we are using "ollama run" and at most 2 non-empty arguments so far.
    if [[ "${COMP_WORDS[1]}" != "run" ]] || [ "$arg_count" -gt 2 ]; then
        return 0
    fi

    # Get the list of models from ollama, skip header (first line) using sed,
    # then use cut to extract only the first column.
    local models
    models=$(ollama list | sed '1d' | cut -f1)

    # Remove duplicate model names by sorting and using uniq.
    local sorted_models
    sorted_models=$(printf '%s\n' "$models" | sort -u)

    # Use compgen to filter the list based on the current token.
    COMPREPLY=( $(compgen -W "$sorted_models" -- "$cur") )
}

# Register the completion function for the "ollama" command.
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#------------------------------------------------------------
#
#How it works:
#
#1. The function first uses either _get_comp_words_by_ref (if available) or falls back to using COMP_WORDS so that the current token (stored in “cur”) is correctly determined.
#
#2. It then counts non‐empty arguments from COMP_WORDS. This lets us restrict completions only when there are at most two words before the current token—so that if the user has already begun entering options after the model name, no completion is offered.
#
#3. The script calls “ollama list” and pipes its output through sed (to drop the header) then cut –f1 to extract just the first column which contains the model names.
#
#4. Duplicate entries are removed by sorting with “sort -u”.
#
#5. Finally compgen is used to filter the available models based on what has been typed so far.
#
#Source this file in your shell (for example, add a line like
#  source /path/to/this_script.sh
#to your .bashrc) and you’ll have model name completions when using “ollama run …”
#
#Feel free to adjust the filtering or the argument-count check as needed for your use case.
#
