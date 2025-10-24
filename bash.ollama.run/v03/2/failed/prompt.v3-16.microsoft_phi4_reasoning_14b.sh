#!/usr/bin/env bash
# Bash completion function for "ollama run <model>"

#<think>We are asked to produce a bash-completion function for command "ollama run <model>" that meets all requirements. Requirements:
#
#The script must be a working, dependency-free bash completion script. It should have inline comments, but only minimal explanation. We then output instructions for installation.
#
#Let's check each requirement in detail:
#
#Requirement breakdown:
#
#1. Triggering: The completion function triggers only when the user is completing the model argument after typing "ollama run". So we need to check that the command is "ollama", and previous word is "run" (or maybe at least ensure that the second token is "run"). The instructions say: "only care that what's being completed follows run." So if the current token index, COMP_CWORD is 2 or more? More precisely, we need to detect that the argument after "ollama run" is the one. But requirement says "if previous word equals 'run' and command equals 'ollama'" check. It says: "Do not fail if there are more than two words in COMP_WORDS—only care that what's being completed follows run." So we can do something like:
#
#if [[ ${COMP_WORDS[0]} != "ollama" ]]; then return 1; fi
#Check maybe the second word is "run", but check previous token of the current command argument. But note: We want to check previous word equals "run". But if there are additional words, they might be harmless? Possibly we can do something like:
#
#if [[ ${COMP_WORDS[1]} != "run" ]]; then return 0; fi
#
#But requirement says: "the simplest reliable check is that the previous word is run and the command is ollama." So maybe: if [[ ${COMP_WORDS[@]: -2} != ... Wait I'll re-read:
#
#"Triggering: The completion must activate only when the user is completing the model argument after typing 'ollama run'. It should work even if extra whitespace or other benign variations exist; the simplest reliable check is that the previous word is 'run' and the command is 'ollama'. Do not fail if there are more than two words in COMP_WORDS—only care that what's being completed follows run." So we want to be sure that current token's previous token equals "run". Let's suppose using compgen with COMPREPLY? Alternatively, we can check: If the second last word is "run", then it's valid.
#
#I need to get the current word from $COMP_WORDS array. The bash completion script uses function ollama_run() maybe?
#
#We want a function that gets triggered on "ollama run" and then does completion suggestions for model names coming from `ollama list`.
#
#Also requirement says: "Run 'ollama list' exactly once". So we must store the output in a variable. The instructions say: "Do not pipe ollama list into a while read loop directly (because that creates a subshell and loses array contents). Instead, store output in a variable and then iterate over that variable safely." How to do that? Possibly we can simply do something like:
#
#models_output=$(ollama list 2>/dev/null) maybe? And then if the variable is empty or command fails then return. But note: "if ollama list fails or returns empty, return without error and provide no completions."
#
#So logic:
#- check that we are in correct position
#- run `ollama list` once. We want to ensure exactly once, so store output.
#- Then if the output is empty, then simply "return 0" with no suggestions.
#- Else, parse it into an array of models.
#
#But careful: The requirement says: "Do not pipe ollama list into a while read loop directly (because that creates a subshell and loses array contents)." Possibly we can do something like:
#models_list=($output) after ensuring output is nonempty. But then note: "if ollama list fails or returns empty, return without error". So if models_list is empty, then return.
#
#- Filtering: Use prefix provided by $cur (current partial word in completion).
#- For each model name from the array, check if it begins with "$cur" using pattern match e.g., [[ $model == "$cur"* ]]. But careful: $cur variable in bash completions is usually defined as the value of current token being completed. But we need to get that value manually using _get_comp_words_by_ref if available. But requirement says: "if you use _get_comp_words_by_ref, include a fallback that manually sets cur and prev from COMP_WORDS/COMP_CWORD if _get_comp_words_by_ref is missing or fails." So I'll write code that calls _get_comp_words_by_ref if function exists, else set cur as ${COMP_WORDS[COMP_CWORD]}.
#
#So do:
#if type _get_comp_words_by_ref &>/dev/null; then
#  _get_comp_words_by_ref cur prev words cword
#else
#  cur=${COMP_WORDS[COMP_CWORD]}
#  prev=${COMP_WORDS[COMP_CWORD-1]}
#fi
#
#But the problem is that I want to check previous word equals "run". But how? The instructions said: "the simplest reliable check is that the previous word is run and the command is ollama." So maybe we can do: if [[ ${prev} != "run" ]] or if first token isn't "ollama", then return. However, requirement says to complete only if what's being completed follows run. But also note: "Do not fail if there are more than two words in COMP_WORDS—only care that what's being completed follows run." So the check is likely:
#if [[ ${COMP_WORDS[1]} != "run" ]]; then return 0; fi
#But careful: The instructions say previous word equals 'run'. But what if user typed extra whitespace? Possibly use ${words[$cword-2]} but that might not be safe. Alternatively, we can do:
#if [ $cword -lt 3 ]; then return 0; fi
#prev=${words[cword-1]}
#if [[ "$prev" != "run" ]]; then return 0; fi
#
#But also check that the first word is ollama: if [[ ${words[0]} != "ollama" ]]; then return 0; fi
#
#So I'll do:
#if [ "${COMP_WORDS[0]}" != "ollama" ]; then return 0; fi
#if [ $COMP_CWORD -lt 2 ] || [ "${COMP_WORDS[1]}" != "run" ]; then return 0; fi
#
#But note: requirement says "Do not fail if there are more than two words in COMP_WORDS—only care that what's being completed follows run." So check the previous word equals "run". But also need to check command is ollama. Possibly:
#if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then return 0; fi
#
#But wait, careful: The instructions say that the simplest reliable check is that previous word equals 'run' and command is 'ollama'. So I'd do:
#if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then return 0; fi
#
#But what if there are extra words? The instructions say not to fail if more than two words in COMP_WORDS. So that's fine.
#
#2. Model list retrieval: We do something like:
#models_output=$(ollama list 2>/dev/null) 
#if [[ -z "$models_output" ]]; then return; fi
#
#But careful: requirement says "If ollama list fails or returns empty, return without error and provide no completions." So we just do nothing if output is empty.
#
#3. Iteration over variable safely: Do something like:
#mapfile -t models_array <<< "$models_output"
#Then iterate using for model in "${models_array[@]}"; do
#But the instructions say "do not pipe ollama list into a while read loop directly" so we must store it then iterate.
#
#4. Prefix filtering: Use current word being completed as prefix. So use:
#if [[ $model == "$cur"* ]]; then push to completions array.
#We also need sorting alphabetically if there are multiple matching models. We can collect them in an array and then sort using e.g., sorted=($(printf "%s\n" "${matches[@]}" | sort)) but careful: That uses a subshell with pipe, which is allowed because coreutils are allowed? But maybe we can do: matches=() then later do:
#if [[ ${#matches[@]} -gt 1 ]]; then
#   # sort using built-ins sorting? But there's no built-in sort in bash. So I'll use GNU sort command.
#But requirement says "use only Bash builtins and GNU coreutils (sort, etc)". So it's fine.
#
#So we can do:
#sorted_matches=($(printf "%s\n" "${matches[@]}" | sort))
#Then assign COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") ) is one possibility. But careful: "either build COMPREPLY manually from filtered & sorted results or use compgen -W ..." So I'll choose to do:
#
#COMPREPLY=($(compgen -W "$(printf "%s\n" "${matches[@]}" | sort)" -- "$cur"))
#
#But wait, check: requirement 5 says "Populate COMPREPLY correctly" either way. But our approach is acceptable if we assume that using compgen with -W and sorted list works fine.
#
#However, be careful with quoting. We need to ensure that the list of models are properly quoted. Alternatively, we can build an array of suggestions then assign it to COMPREPLY.
#
#But requirement 4: Sorting alphabetically before assigning to COMPREPLY.
#We want to do:
#matches=() maybe store all matches
#Then sorted=$(printf "%s\n" "${matches[@]}" | sort)
#Then use compgen -W "$sorted" -- "$cur"
#
#So yes that works.
#
#5. Graceful failure: If ollama list fails or returns empty, then just "return 0". So do if [ -z "$models_output" ]; then return; fi
#No completions are provided. But we must not produce error message.
#
#6. No external dependencies: Use only bash built-ins and GNU coreutils (sort) so that's fine.
#
#7. Wiring: Attach the function to `ollama` so that typing "ollama run <Tab>" triggers it. Typically, we do something like:
#complete -F ollama_run ollama
#So then when user types "ollama run", our function gets triggered.
#
#8. Installation instructions: At end include minimal example of where to save or source the script and how to activate it immediately (e.g., add a source line to .bashrc and reload). So I'll append at the end:
#Installation snippet:
## Place this file in /etc/bash_completion.d/ollama-completion.bash
## Or source this file from your .bashrc: source /path/to/ollama-completion.bash
#
#I must output only complete script with comments and installation snippet. No additional explanation.
#
#Let's produce the bash completion function. I'll name it "ollama_run_completion" maybe, or simply "ollama_run".
#
#Maybe function name: _ollama_run_completion() then attach to command "ollama". But requirement says: "Attach the function to ollama so that typing ollama run <Tab> triggers it." So we need to define a function with some name and then call complete -F <function_name> ollama.
#
#We want our script to be dependency-free. It uses bash built-ins, compgen, sort command from coreutils.
#I'll produce inline comments like "# ..." for each step.
#
#Let's check the code structure:
#
#
##!/usr/bin/env bash
## Bash completion function for 'ollama run <model>'
#_ollama_run_completion() {
#    # Check if we're completing after "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]:-}" != "run" ]]; then
#        return 0
#    fi
#
#    # Get current word being completed. Use _get_comp_words_by_ref if available.
#    local cur prev words cword
#    if type _get_comp_words_by_ref &>/dev/null; then
#        _get_comp_words_by_ref cur prev words cword
#    else
#        cur=${COMP_WORDS[COMP_CWORD]}
#        prev=${COMP_WORDS[COMP_CWORD-1]}
#    fi
#
#    # Retrieve model list from 'ollama list' only once.
#    local models_output
#    models_output=$(ollama list 2>/dev/null)
#    if [[ -z "$models_output" ]]; then
#        return 0
#    fi
#
#    # Split the output into an array of lines (models).
#    mapfile -t models_array <<< "$models_output"
#
#    # Filter models by prefix and collect matches.
#    local matches=()
#    for model in "${models_array[@]}"; do
#        if [[ $model == "$cur"* ]]; then
#            matches+=("$model")
#        fi
#    done
#
#    # If no match, return.
#    if [ ${#matches[@]} -eq 0 ]; then
#        return 0
#    fi
#
#    # Sort matching models alphabetically.
#    local sorted_matches
#    readarray -t sorted_matches < <(printf "%s\n" "${matches[@]}" | sort)
#
#    # Populate COMPREPLY with suggestions.
#    COMPREPLY=( $(compgen -W "$(printf '%s ' "${sorted_matches[@]}")" -- "$cur") )
#}
#
## Attach the function to the 'ollama' command.
#complete -F _ollama_run_completion ollama
#
#
#But note: There's a detail regarding the check "if [[ "${COMP_WORDS[1]:-}" != "run" ]]; then ...". But COMP_WORDS is an array, so if there are not enough elements, we want to return 0. But requirement says "Do not fail if there are more than two words in COMP_WORDS—only care that what's being completed follows run." So maybe we require at least second word equals "run" regardless of how many words there are. But I worry: If there is more than two words, the condition might still be satisfied as long as COMP_WORDS[1] equals run.
#
#But check if user typed "ollama run something tab". Then COMP_WORDS would contain e.g.:
#COMP_WORDS[0]="ollama"
#COMP_WORDS[1]="run"
#So that's good.
#If user didn't type enough words, then return 0 gracefully.
#
#I need to ensure no completions in other cases.
#
#I must also consider the fact that _get_comp_words_by_ref is available sometimes but might not be present. So I'll do fallback.
#
#Also check: "mapfile -t models_array <<< "$models_output"". This should work fine, it's reading from string into array. But does mapfile require a file? It's used with here-string so that's allowed in bash >= 4. However, requirement says Linux support only and dependency free. So I'll assume bash version is okay.
#
#Alternatively: "readarray -t models_array <<< "$models_output" ". But note that readarray is similar to mapfile, which is available in newer versions of bash. But if we are using bash completion script, it's likely older maybe. But requirement says dependency free and linux support only. So I'll assume Bash 4+.
#
#I can also do: models_array=($models_output) but that might split on whitespace and cause issues if model names have spaces. But likely they don't. The instructions didn't say anything about spaces in model names. But perhaps it's safe to assume each line is a separate model with no internal spaces? But what if there are spaces? Possibly not. I think using mapfile or readarray is better.
#
#I'll use mapfile -t models_array <<< "$models_output" because that's standard in bash.
#
#Then filter with for loop: "if [[ $model == "$cur"* ]]; then matches array push." That's good.
#Then if no match, return 0.
#Sort them using "printf %s\n ... | sort". But I'll do: sorted_matches=($(printf "%s\n" "${matches[@]}" | sort)).
#Yes.
#
#I need to populate COMPREPLY. Possibly we do:
#COMPREPLY=( $(compgen -W "$(printf '%s ' "${sorted_matches[@]}")" -- "$cur") )
#But careful: If no completions are available, compgen returns nothing.
#This is fine.
#
#I must also check if matches array is empty.
#
#Yes.
#
#That's the function.
#
#Then attach it with complete -F _ollama_run_completion ollanda. But requirement says "complete -F <function> ollama", so that should be correct.
#
#Finally, I'll add installation instructions as comment lines at end:
#Installation snippet: 
## To enable this completion script, source it in your .bashrc or place it in /etc/bash_completion.d/ (Debian-based systems).
## For example, add the following line to ~/.bashrc:
##   source /path/to/ollama-completion.bash
#
#I'll include that at the end.
#
#That's all.
#
#Also note: requirement says "by default do not reply with markdown formatting" so I'll output plain text code. But instructions say "By default, do not reply with Markdown formatting unless requested." So I'll just output plain text code maybe as a block but without markdown formatting markers? I guess I'll output plain text.
#
#I must also check that no extra explanations appear.
#
#Let me produce the final answer in plain text (with triple backticks maybe? But instructions says by default do not reply with Markdown unless requested. So I'll simply output plain text code.)
#
#I'll now produce final answer.</think>

_ollama_run_completion() {
    # Only trigger completion if the command is "ollama" and the second word is "run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || -z "${COMP_WORDS[1]}" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Get the current word being completed.
    local cur prev words cword
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref cur prev words cword
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Retrieve the list of models from "ollama list" (only once)
    local models_output
    models_output=$(ollama list 2>/dev/null)
    if [[ -z "$models_output" ]]; then
        return 0
    fi

    # Split the output into an array; each line is expected to be a model name.
    mapfile -t models_array <<< "$models_output"

    # Filter models that start with the current word (prefix matching)
    local matches=()
    for model in "${models_array[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # If no match was found, return without completions.
    if [ ${#matches[@]} -eq 0 ]; then
        return 0
    fi

    # Sort the matching models alphabetically using GNU sort.
    local sorted_matches
    readarray -t sorted_matches < <(printf "%s\n" "${matches[@]}" | sort)

    # Populate COMPREPLY with suggestions generated from the sorted list.
    COMPREPLY=( $(compgen -W "$(printf '%s ' "${sorted_matches[@]}")" -- "$cur") )
}

# Attach the completion function to the "ollama" command.
complete -F _ollama_run_completion ollama

# Installation:
# To enable this completion script, either source it in your ~/.bashrc or place it in /etc/bash_completion.d/ (for Debian-based systems).
#
# For example, add the following line to your ~/.bashrc:
#   source /path/to/this_script.bash
# Then reload your shell or run "source ~/.bashrc".