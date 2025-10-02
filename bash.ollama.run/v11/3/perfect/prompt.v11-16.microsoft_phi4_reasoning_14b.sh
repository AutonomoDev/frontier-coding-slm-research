#<think>We need to produce a robust bash completion script for `ollama run` command that dynamically completes model names retrieved from ollama list output. The script should support colon handling and fallback.
#
#I'll generate a Bash script with function `_ollama_completions`, which is triggered when completions are needed by "complete -F _ollama_completions ollama". Requirements:
#
#1. Function named `_ollama_completions` that checks if command name equals "ollama" and previous word is "run", otherwise no completion.
#2. It must use `if ! _get_comp_words_by_ref -n : cur prev; then fallback to COMP_WORDS`.
#3. Then, check if `prev` equals "run". If not, return empty completions array (set COMPREPLY=()).
#4. Then retrieve model names by executing `ollama list`. Check command exists.
#5. Parse the output using awk or while loop skipping header. We have sample ollama list output format:
#```
#NAME ID SIZE MODIFIED
#codegemma:7b 0c96700aaada 5.0 GB 12 days ago
#codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
#...
#```
#We need to extract the first column (the model names). The output is separated by whitespace columns, so we can use awk or similar.
#6. Then filter matches using array iteration and pattern matching against $cur. We'll store possible completions in an array sorted.
#
#The script must call __ltrim_colon_completions "$cur" to handle colon completions.
#
#7. At the end, register completion: "complete -F _ollama_completions ollama".
#
#We need inline comments that explain steps. It's critical not to include any markdown commentary outside source code comments.
#
#I'll produce a single contiguous block with valid bash script code containing function `_ollama_completions`.
#
#Let's design it:
#
#```
#_ollama_completions() {
#    # Ensure we are completing 'ollama run'
#    local prev cur
#    if ! _get_comp_words_by_ref -n : cur prev 2>/dev/null; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Only provide completions when previous word is 'run'
#    if [ "${prev}" != "run" ]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Check if ollama command exists
#    if ! command -v ollama >/dev/null 2>&1; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Get list of models using 'ollama list' and parse the first column, skipping header row.
#    local models raw_model model_list sorted_matches
#    models=()
#    raw_model=$(ollama list 2>/dev/null)
#    if [ -z "$raw_model" ]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Parse output: skip header, extract first column (model name) from each line.
#    while IFS=$'\n' read -r line; do
#        # Skip header line starting with NAME or empty lines
#        if [[ $line =~ ^NAME ]]; then
#            continue
#        fi
#        # Use awk to extract first field: assuming fields are space-separated.
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done <<< "$raw_model"
#
#    # Filter matches for current word ($cur) ignoring colon splitting issues.
#    local suggestions=()
#    for m in "${models[@]}"; do
#        if [[ "$m" == "$cur"* ]]; then
#            suggestions+=("$m")
#        fi
#    done
#
#    # Sort the suggestions alphabetically.
#    IFS=$'\n' sorted_matches=$(printf "%s\n" "${suggestions[@]}" | sort -u)
#
#    # Generate COMPREPLY using compgen with word list.
#    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#
#    # Adjust the completions to handle colons correctly.
#    __ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completions ollama
#```
#
#We need to produce final code with inline comments. But must be careful: The instructions require that we only output a single block of Bash code, no additional commentary outside source code comments.
#
#I'll produce final code accordingly.
#
#Potential pitfalls:
#- Make sure to use double quotes in condition check "[ "${prev}" != "run" ]", as required.
#- Must include fallback for systems without bash completion: if _get_comp_words_by_ref not available then set cur and prev using COMP_WORDS[COMP_CWORD] etc.
#- Use __ltrim_colon_completions, so must be defined somewhere. But probably it's provided by bash-completion package. So it's fine.
#
#Edge details:
#- The script should use local variables with proper scoping (local).
#- It should check for command existence "ollama", using if ! command -v ollama >/dev/null 2>&1; then ...
#- Use while read loop on raw_model. Alternatively, we can pipe to awk, but we need to skip header. But careful: The sample output's first line is a header with "NAME ID SIZE MODIFIED". We might want to use tail -n +2 if possible.
#
#I'll produce code that uses while IFS=$'\n' read loop:
#```
#while IFS=$'\n' read -r line; do
#   if [[ $line =~ ^NAME ]]; then continue; fi
#   model=$(echo "$line" | awk '{print $1}')
#   models+=("$model")
#done <<< "$raw_model"
#```
#
#Alternatively, we could use tail -n +2 "$some file", but since output is from command substitution, it's better to do while read.
#
#- Sorting: Using IFS=$'\n' sorted_matches=$(printf "%s\n" "${suggestions[@]}" | sort -u)
#
#Be careful with the __ltrim_colon_completions call. It must be called after compgen. But according to instructions "call __ltrim_colon_completions "$cur"" right after generating COMPREPLY.
#
#I'll produce final code block:
#
#We need a robust solution that handles colon completions.
#
#I'll produce final answer with inline comments and no additional commentary outside source code comment markers. We'll use "# ..." for inline comments.
#
#We must ensure that it's strictly Bash code, no markdown formatting.
#
#I'll now produce the final answer in one contiguous block.</think>
_ollama_completions() {
    # Retrieve current and previous words using _get_comp_words_by_ref if available;
    # fallback to standard COMP_WORDS parsing otherwise.
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev 2>/dev/null; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only provide completions when the previous word is "run"
    if [ "${prev}" != "run" ]; then
        COMPREPLY=()
        return 0
    fi

    # Check if the 'ollama' command exists before proceeding.
    if ! command -v ollama >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve model names by executing "ollama list" and capturing its output.
    local models raw_model suggestion sorted_matches suggestions
    models=()
    raw_model=$(ollama list 2>/dev/null)
    if [ -z "$raw_model" ]; then
        COMPREPLY=()
        return 0
    fi

    # Parse the ollama list output, skipping the header row.
    while IFS=$'\n' read -r line; do
        # Skip the header line that starts with "NAME"
        if [[ $line =~ ^NAME ]]; then
            continue
        fi
        # Extract the first column (model name) using awk.
        suggestion=$(echo "$line" | awk '{print $1}')
        models+=("$suggestion")
    done <<< "$raw_model"

    # Filter model names based on the current user input ($cur).
    suggestions=()
    for m in "${models[@]}"; do
        if [[ "$m" == "$cur"* ]]; then
            suggestions+=("$m")
        fi
    done

    # Sort the suggestions alphabetically and remove duplicates.
    IFS=$'\n' sorted_matches=$(printf "%s\n" "${suggestions[@]}" | sort -u)

    # Generate completions using compgen with the list of model names.
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Adjust the completion display to correctly handle colon-separated words.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completions ollama
