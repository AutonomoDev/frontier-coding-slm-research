#<think>We are given a prompt which asks us to generate a robust bash completion script for "ollama run <model>" that satisfies certain conditions. We have requirements: It should only activate if COMP_WORDS[0] is "ollama" and COMP_WORDS[1] is "run". The colon handling is critical, must use __ltrim_colon_completions after setting COMPREPLY. And parse ollama list output properly.
#
#We are given instructions with steps:
#- Must check array indexing for command and run
#- Use _get_comp_words_by_ref -n : cur prev if possible
#- Fall back to manual extraction from COMP_WORDS.
#- Parse models by: Check that "ollama" exists (command -v ollama &>/dev/null)
#- Then run `ollama list 2>/dev/null`
#- Parse line-by-line, skip header line "NAME ID SIZE MODIFIED"
#- Extract first column using awk '{print $1}'.
#- Build array of model names
#- Filter models matching current prefix and sort results
#- Set COMPREPLY using compgen.
#
#Also must call __ltrim_colon_completions "$cur" at the end
#
#We need to output only bash code, no markdown formatting. We have instructions "Include inline comments explaining critical sections". The script is production ready robust and handle edge cases such as missing models, command not found etc.
#
#I'll produce a script that defines function _ollama_completions then registers it with complete -F _ollama_completions ollama at the end. So I'll output code like:
#
#```
#_ollama_completions() {
#    # Check if the command is "ollama run", using correct indexing
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#       COMPREPLY=()
#       return
#    fi
#
#    local cur prev
#    # Use _get_comp_words_by_ref to handle colon in completions properly (if available)
#    if type _get_comp_words_by_ref >/dev/null 2>&1; then
#         _get_comp_words_by_ref -n : cur prev
#    else
#         cur="${COMP_WORDS[COMP_CWORD]}"
#         prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Check if ollama command exists
#    if ! command -v ollama &>/dev/null; then
#        COMPREPLY=()
#        return
#    fi
#
#    local models=()
#
#    # Run "ollama list" to get the list of models, ignoring error output.
#    local output
#    if output=$(ollama list 2>/dev/null); then
#         # Parse the output line-by-line, skipping header and extracting first column
#         while IFS= read -r line; do
#              # Skip empty lines or header with "NAME"
#              if [[ "$line" =~ ^\s*NAME ]]; then
#                   continue
#              fi
#
#              # Extract model name (first field) using awk to account for spaces etc.
#              local model
#              model=$(echo "$line" | awk '{print $1}')
#              models+=("$model")
#         done <<< "${output}"
#    fi
#
#    # Filter completions matching the current prefix.
#    COMPREPLY=( $(compgen -W "$(printf "%s\n" "${models[@]}")" -- "$cur") )
#    
#    # Fix colon display by trimming leading colons from completions
#    __ltrim_colon_completions "$cur"
#}
#
#complete -F _ollama_completions ollama
#```
#
#I'll produce code with inline comments explaining critical sections. I'll check that it meets all requirements: Check COMP_WORDS[0] and [1]. It uses proper colon handling. It calls __ltrim_colon_completions at the end. It parses output from "ollama list" properly skipping header line "NAME". It handles missing ollama command gracefully. And works with model names containing colons.
#
#I'll produce code with no markdown formatting (just plain text). I need to check that I follow instructions: "OUTPUT ONLY BASH CODE" so my answer should not include any explanations, just the script code. But instructions require inline comments in code. So it's acceptable to include inline comments as long as it's only bash code.
#
#I'll produce the output now. We must include registration at end.
#
#Potential pitfalls: The function _get_comp_words_by_ref is typically provided by bash-completion packages, but we can assume it's available if user uses bash completion.
#
#We must check that __ltrim_colon_completions exists? It should exist because it's a function from bash-completion. But if not, script may break. The instructions don't mention that so I'll simply call it.
#
#I might need to do something like "compgen -W" to produce completions. Also, after generating completions we call __ltrim_colon_completions "$cur". We must be careful with colon handling: if the user typed a model name containing colon, then current word is empty because of splitting? But instructions say to use _get_comp_words_by_ref -n : cur prev. So that's correct.
#
#I'll produce code accordingly.
#
#Double-check that "command -v ollama &>/dev/null" check ensures command exists. We handle missing output by checking if output variable is non-empty with "if output=$(ollama list 2>/dev/null); then". But what if output returns a header line? I must skip header lines with "if [[ "$line" =~ ^\s*NAME ]]; then continue", but that's not exactly robust because the header might have additional spaces. The sample output is:
##NAME                    ID              SIZE    MODIFIED
#codegemma:7b           0c96700aaada    5.0 GB  12 days ago
#codellama:13b          9f438cb9cd58    7.4 GB  12 days ago
#codellama:34b          685be00e1532    19 GB   12 days ago
#```
#I can check if line starts with "NAME" using regex. That is fine.
#
#I must also include inline comment explaining colon handling, and colon display fix as well.
#
#I'll produce code accordingly.
#
#I'll produce the output now. We'll produce plain text.
#</think>
_ollama_completions() {
    # Only activate completion when command is "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    local cur prev

    # Handle colon splitting in completions:
    # If _get_comp_words_by_ref is available, use it to prevent Bash from splitting on colons.
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the "ollama" command exists; exit gracefully if not.
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models=()
    local output

    # Run "ollama list" and capture its output while suppressing errors.
    if output=$(ollama list 2>/dev/null); then
        # Parse the output line-by-line:
        while IFS= read -r line; do
            # Skip header (e.g., "NAME ID SIZE MODIFIED")
            [[ "$line" =~ ^\s*NAME ]] && continue

            # Extract only the first column which is the model name.
            local model
            model=$(echo "$line" | awk '{print $1}')
            models+=("$model")
        done <<< "${output}"
    fi

    # Generate completion suggestions based on current prefix (cur)
    COMPREPLY=( $(compgen -W "$(printf "%s\n" "${models[@]}")" -- "$cur") )

    # Fix colon display: trim leading colons from completions.
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
