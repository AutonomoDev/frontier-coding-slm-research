#<think>We are asked with the prompt " ==== PROMPT v12 ====" and then instructions, including sample output of ollama list. It says: "You are a Bash script generator. Your only job is to output the Bash code. DO NOT ADD ANY TEXT OUTSIDE THE CODE! NO MARKDOWN, NO HEADERS, NO EXPLANATIONS." So answer with pure bash code.
#
#I have to produce a complete bash completion script with function _ollama_completions that meets all requirements.
#
#Let's re-read instructions:
#
#- Create function called `_ollama_completions`.
#
#- Check if the first word is "ollama" and second word (previous) is "run". That means check: if COMP_WORDS[0] != ollama OR COMP_WORDS[1] != run then return. But careful: The instruction says:
#"if the first word is not 'ollama' or prev is not 'run', set COMPREPLY=() and return." So do that.
#
#- Then "Handle Colons (IMPORTANT): Try if ! _get_comp_words_by_ref -n : cur prev; then fallback. But instructions:
#    try:
#        if ! _get_comp_words_by_ref -n : cur prev; then
#            fallback, using: cur="${COMP_WORDS[COMP_CWORD]}" and prev="${COMP_WORDS[COMP_CWORD-1]}"
#    So code should be:
#
#```
#if ! _get_comp_words_by_ref -n : cur prev; then
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#```
#
#But careful: We need to check for existence of the function _get_comp_words_by_ref. If it doesn't exist, fallback.
#
#- Then "Completion Logic:" if previous word is run:
#    Check if command -v ollama &> /dev/null exists.
#
#- Then run `ollama list 2>/dev/null` and read line by line in a while loop.
#    But need to parse the output: skip header row "NAME ID SIZE MODIFIED" and empty lines. And extract only model names using awk '{print $1}' or similar. The sample output includes "NAME ID SIZE MODIFIED", so I can check if line is header, then skip.
#
#- Then add to local array called models if not empty.
#    But instructions: "Add to a local array called models if not empty." So code something like:
#```
#models=()
#while read -r line; do
#   # Skip header and empty lines:
#   [[ "$line" =~ ^NAME ]] && continue
#   [[ -z "$line" ]] && continue
#   model=$(echo "$line" | awk '{print $1}')
#   if [ -n "$model" ]; then
#       models+=("$model")
#   fi
#done <<< "$(ollama list 2>/dev/null)"
#```
#But need to check if "models" array is empty, then set COMPREPLY=() and return.
#
#- Then create another array for matches: loop through each model in the models array, if it starts with "$cur", add to matches.
#   But careful: since names contain colons, so we use a pattern matching maybe using parameter expansion or regex. Use e.g.:
#```
#matches=()
#for m in "${models[@]}"; do
#   [[ $m == $cur* ]] && matches+=("$m")
#done
#```
#
#- Then sort the matches array: sorted_matches=$(printf '%s\n' "${matches[@]}" | sort) and then set COMPREPLY to compgen -W "$sorted_matches" -- "$cur".
#
#So code should be something like:
#```
#if [ ${#matches[@]} -eq 0 ]; then
#   COMPREPLY=()
#else
#   sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#   COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#fi
#```
#
#- Then after COMPREPLY, ALWAYS call __ltrim_colon_completions "$cur".
#
#So I need to add: `__ltrim_colon_completions "$cur"`
#
#But careful: The function __ltrim_colon_completions is provided by bash completion library maybe. But anyway.
#
#- Finally, register the completions with complete -F _ollama_completions ollama
#
#- Use local variables.
#
#- Code should be pure Bash code, no markdown formatting, and not any text outside the code.
#
#- Comments: Add comments explaining each part especially colon handling, parsing, why __ltrim_colon_completions is needed. So add # comments.
#
#I must produce a file that can be saved as .sh and sourced. I'll use "#!/bin/bash" maybe. But instructions said "output only the bash code."
#
#But instructions say: "DO NOT ADD ANY TEXT OUTSIDE THE CODE! NO MARKDOWN, NO HEADERS, NO EXPLANATIONS." So I just output pure code.
#
#I need to produce a single bash script text that meets all requirements.
#
#Let's check each step:
#
#1. Function structure: function _ollama_completions() { ... }
#
#2. Subcommand check: if the first word is not "ollama" or second is not "run", then set COMPREPLY=() and return.
#
#I must be careful to get COMP_WORDS variable, since the function should use COMP_WORDS and COMP_CWORD variables. So code:
#
#```
#if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
#    COMPREPLY=()
#    return 0
#fi
#```
#
#But note: Some systems might require a different syntax for array indexing maybe use "${COMP_WORDS[0]}". Yes.
#
#3. Handle colons:
#```
#if ! _get_comp_words_by_ref -n : cur prev; then
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#```
#But instructions say "prev is not run, set COMPREPLY=() and return early." So we need to check that after setting up cur/prev.
#
#I must also check if prev equals "run". But already checked earlier. Actually I'm re-check: The instruction said "if the first word is not 'ollama' or prev is not 'run', set COMPREPLY=() and return early." So code can be placed before colon handling maybe.
#
#But then, it's recommended to call __get_comp_words_by_ref to avoid colon splitting issues. But must check if function exists; if not fallback with assignment of cur/prev from COMP_WORDS array.
#
#I should put that after subcommand check?
#
#Maybe the structure:
#```
#function _ollama_completions() {
#    # Only complete for "ollama run"
#    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Handle colon splitting: _get_comp_words_by_ref if available, fallback otherwise.
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#   ...
#}
#```
#
#4. Then "Completion Logic:" if prev is "run" (we already checked that, but we can check again for safety or maybe not necessary). But anyway.
#
#We then check if command -v ollama &>/dev/null returns success, if not then set COMPREPLY=() and return early.
#```
#if ! command -v ollama &> /dev/null; then
#   COMPREPLY=()
#   return 0
#fi
#```
#
#Then run `ollama list` to get output. But since we must parse it carefully: skip header "NAME ID SIZE MODIFIED" and empty lines.
#
#We do:
#```
#models=()
#while IFS= read -r line; do
#    # Skip header and empty lines.
#    [[ "$line" =~ ^NAME ]] && continue
#    [[ -z $line ]] && continue
#    model=$(echo "$line" | awk '{print $1}')
#    if [ -n "$model" ]; then
#        models+=("$model")
#    fi
#done < <(ollama list 2>/dev/null)
#```
#However, I must check if the function "ollama" exists. But already did.
#
#- Then if models array is empty, set COMPREPLY=() and return early.
#So:
#```
#if [ ${#models[@]} -eq 0 ]; then
#    COMPREPLY=()
#    return 0
#fi
#```
#
#Then create matches array: loop over models array. For each m in "${models[@]}", if it starts with "$cur", add to matches. But careful: Because $cur might be empty? But instructions say "if it starts with "$cur"". So I can use parameter expansion "[[ $m == $cur* ]]" then add.
#
#```
#matches=()
#for model in "${models[@]}"; do
#    if [[ "$model" == $cur* ]]; then
#       matches+=("$model")
#    fi
#done
#```
#
#Then sort the matches array. But instructions: "sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)". Then set COMPREPLY to compgen with sorted_matches.
#
#But careful: If no matches, then we want empty suggestions. So do:
#```
#if [ ${#matches[@]} -eq 0 ]; then
#    COMPREPLY=()
#else
#    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#fi
#```
#
#Then call __ltrim_colon_completions "$cur". So:
#```
#__ltrim_colon_completions "$cur"
#```
#
#That ensures colon splitting.
#
#- Then complete with "complete -F _ollama_completions ollama" is placed outside the function, as registration.
#
#Add comments for each part. Comments: # Only complete for "ollama run", etc.
#
#I need to produce pure code with no extra text.
#
#So final code (should be pure Bash):
#
#```
##!/bin/bash
## Bash completion script for "ollama run"
#_ollama_completions() {
#    # Only complete if command is "ollama" and second argument is "run"
#    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Handle colon splitting: Use _get_comp_words_by_ref if available; fallback otherwise.
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Check that the 'ollama' command exists
#    if ! command -v ollama &> /dev/null; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Get list of models from "ollama list", ignoring header and empty lines.
#    local models=()
#    while IFS= read -r line; do
#        # Skip header row ("NAME ID SIZE MODIFIED") and empty lines.
#        [[ "$line" =~ ^NAME ]] && continue
#        [[ -z "$line" ]] && continue
#        model=$(echo "$line" | awk '{print $1}')
#        if [ -n "$model" ]; then
#            models+=("$model")
#        fi
#    done < <(ollama list 2>/dev/null)
#
#    # If no models found, exit without suggestions.
#    if [ ${#models[@]} -eq 0 ]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Build matches array: add models that start with the current input "$cur".
#    local matches=()
#    for m in "${models[@]}"; do
#        if [[ "$m" == $cur* ]]; then
#            matches+=("$m")
#        fi
#    done
#
#    # If no matching models, exit without suggestions.
#    if [ ${#matches[@]} -eq 0 ]; then
#        COMPREPLY=()
#    else
#        # Sort the matches and generate completion list.
#        local sorted_matches
#        sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#        COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#    fi
#
#    # Fix colon-splitting issues for bash completion.
#    __ltrim_colon_completions "$cur"
#}
#
#complete -F _ollama_completions ollama
#```
#
#I must output exactly that code without any extra markdown formatting. But instructions said "no markdown formatting", so I'll not wrap with triple backticks.
#
#I'll produce the pure code. Let me produce it as plain text with no markdown formatting.
#
#I'll now produce the final answer in a code block? The instruction says "By default, do not reply with Markdown formatting unless requested." So I'll output plain text.
#
#I'll produce answer: I'll put code and then nothing else.
#
#I'll produce my final answer.</think>
#!/bin/bash
# Bash completion script for "ollama run"
_ollama_completions() {
    # Only complete if the command is "ollama" and its second argument is "run"
    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colon splitting:
    # _get_comp_words_by_ref (provided by bash-completion) avoids issues with names containing colons.
    # If not available, fall back to using the COMP_WORDS array directly.
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Ensure that the "ollama" command exists before proceeding.
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve the list of models from "ollama list".
    # Skip the header ("NAME ID SIZE MODIFIED") and any empty lines.
    local models=()
    while IFS= read -r line; do
        [[ "$line" =~ ^NAME ]] && continue
        [[ -z "$line" ]] && continue
        model=$(echo "$line" | awk '{print $1}')
        if [ -n "$model" ]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # If no models were found, exit without any completions.
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return 0
    fi

    # Build an array of matching models that start with the current input "$cur".
    local matches=()
    for m in "${models[@]}"; do
        if [[ "$m" == $cur* ]]; then
            matches+=("$m")
        fi
    done

    # If no matches are found, clear completions.
    if [ ${#matches[@]} -eq 0 ]; then
        COMPREPLY=()
    else
        # Sort the matched models and generate the completion list.
        local sorted_matches
        sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
        COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
    fi

    # Correct any colon-splitting issues in bash completions.
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
