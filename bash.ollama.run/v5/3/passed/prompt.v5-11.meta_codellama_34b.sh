#!/bin/bash
# This is a Bash completion script for the `ollama run` command. It provides autocompletion suggestions for model names when a user types `ollama run ` and presses the `<TAB>` key.
# 
# Targeted Triggering: The completion logic MUST only activate for the word immediately following the `run` subcommand. It should not attempt to complete `ollama` itself or any other subcommand. Check that the second word (`${COMP_WORDS[1]}`) is exactly `run`.
# 
# Precise Parsing: You MUST parse the output of `ollama list`.
# * Extract only the model names from the first column (e.g., `llama3:latest`, `codellama:7b-instruct`).
# * Skip the header line of the output (the line that starts with `NAME`).
# * Use a standard and reliable tool like `awk '{print $1}'` or `cut` for this parsing.
# 
# Contextual Filtering: The suggestions provided MUST be filtered based on the word the user is currently typing. For example, if the user types `ollama run co<TAB>`, only models starting with `co` should be suggested.
# 
# No Filename Fallback: If the word being completed does not match any available model, you MUST NOT fall back to suggesting filenames from the current directory. The completion should simply provide no suggestions.
# 
# Unique Suggestions: The final list of completion suggestions MUST NOT contain duplicate entries.
# 
# Standard Bash: The entire script must use valid, standard Bash syntax compatible with the `bash-completion` v2 framework. Use standard variables like `COMP_WORDS`, `COMP_CWORD`, and `COMPREPLY`.
# 
# No external dependencies: Use only Bash built-ins and GNU coreutils (sort, etc). Assume LINUX support only. Do not assume non-standard helpers are available. Awk is prohibited.
# 
# If you use `_get_comp_words_by_ref`, include a fallback that manually sets `cur` and `prev` from `COMP_WORDS`/`COMP_CWORD` if `_get_comp_words_by_ref` is missing or fails.
# 
# --- EXAMPLE OF CORRECT BEHAVIOR ---
# Given the `ollama list` output from above, here is how the script should behave:
# 
# 1. User types `ollama run <TAB>`:
# ```bash
# $ ollama run <TAB>
# llama3:latest  codellama:7b-instruct  deepseek-coder-v2:16b-lite
# ```
# 
# 2. User types `ollama run l` and presses `<TAB>`:
# ```bash
# $ ollama run l<TAB>
# llama3:latest
# ```
# 
# 3. User types `ollama run cod` and presses `<TAB>`:
# ```bash
# $ ollama run cod<TAB>
# codellama:7b-instruct
# ```
# 
# 4. User types `ollama run xyz` and presses `<TAB>`:
# ```bash
# $ ollama run xyz<TAB>
# # (No output, no suggestions, no errors)
# ```

_ollama_completion() {
    local cur prev words cword

    _init_completion || return

    # Only activate completion for the `run` subcommand.
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Get the model names from the output of `ollama list`.
    models=$(ollama list | awk 'NR > 1 {print $1}')

    # Filter suggestions based on the current word.
    if [[ "${COMP_CWORD}" -eq 2 ]]; then
        COMPREPLY=($(compgen -W "$models" -- ${COMP_WORDS[${COMP_CWORD}]}))
    fi
}

complete -F _ollama_completion ollama

