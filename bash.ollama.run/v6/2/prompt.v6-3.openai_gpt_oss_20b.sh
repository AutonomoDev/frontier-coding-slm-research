#Thinking...
#We need to output a script. It must define a function and register it. We'll produce script using _get_comp_words_by_ref with fallback. We'll need to parse ollama list: use "ollama list" output, skip header line, extract first column. Use cut -f1 -d ' ' maybe but spaces can be multiple. Better use awk to get first column. But requirement says use cut. However cut can't handle multiple spaces unless we specify FS? cut can't specify delimiter as regex. So we might use 'awk' though requirement says use cut. But we can use cut -f1 -d ' ' only works for single spaces. But the output uses spaces and columns, but first column may have spaces? The output has "NAME", "ID", etc. The name column contains the model name; it's separated by spaces. But there may be multiple spaces, but we can pipe through awk to extract first field. But requirement says "Use a standard and reliable tool like cut for this parsing." We can still use cut after trimming multiple spaces? Could use 'cut -d' ' -f1' but that only works for single space. But we can use 'awk', but that violates requirement. However we can use cut with 'cut -f1 -d' ' ' ' | tr -s ' '. Wait we could first 'awk' or 'sed' to replace multiple spaces with single. But that uses awk or sed. Maybe we can use cut with '-d' ' ' but we need to collapse spaces first using 'sed' which is standard. But using sed is okay. Let's use 'ollama list | sed 1d | awk '...''? That uses awk. But requirement says must parse output of ollama list, extract only model names, skip header. Use standard tool like cut. But doesn't say cannot use awk. It says use a standard and reliable tool like cut. That implies we should use cut but maybe can combine with other tools. But to be safe, we can use 'cut -f1 -d' ' ' after collapsing spaces to single. So use 'ollama list | sed 1d | tr -s ' ' | cut -d' ' -f1'. That should work.
#
#Now parse: store into array. Then filter based on current word.
#
#Need to avoid duplicate suggestions: use sort -u.
#
#Return via COMPREPLY array.
#
#No fallback to filenames.
#
#Now we need to ensure that we only trigger when first word is 'ollama' and previous word is 'run'. We'll check COMP_WORDS[0] and COMP_WORDS[COMP_CWORD-1].
#
#Also we need to check that cur is empty or starts with something.
#
#Ok.
#
#Implementation:
#
#```
#_ollama_run_completion() {
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur prev words cword || {
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    }
#    # only if first word is ollama and prev is run
#    if [[ ${COMP_WORDS[0]} != ollama ]] || [[ $prev != run ]]; then
#        return
#    fi
#    # get list of models
#    local models
#    models=$(ollama list | sed 1d | tr -s ' ' | cut -d' ' -f1 | sort -u)
#    # Filter
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#}
#complete -F _ollama_run_completion ollama
#```
#
#But we need to avoid filename fallback: using compgen -W only will only use given words; not fallback to filenames. If no matches, COMPREPLY will be empty.
#
#Ensure unique suggestions: sort -u ensures unique.
#
#Need to make sure we handle when cur is empty: compgen will match all.
#
#Edge: if user types "ollama run " then cur will be empty string; compgen will generate all models.
#
#Also we might want to trim leading/trailing spaces of models.
#
#Also we might need to avoid returning suggestions if models empty: return.
#
#Now produce final script with comments starting with # for each non-code line.
#
#Let's craft script.
#...done thinking.

#!/usr/bin/env bash
# Bash completion script for the `ollama run` command
#
# This script provides autocompletion for local Ollama model names
# when the user types `ollama run ` followed by <TAB>.
#
# Requirements:
#   * Only activates for the word immediately following the `run` subcommand.
#   * Parses the output of `ollama list`, extracting only the model names
#     (first column) while skipping the header line.
#   * Provides context‑sensitive suggestions based on the current word.
#   * Does not fall back to filenames or offer any other completions.
#   * Ensures the suggestion list is unique and sorted.
#   * Uses only standard Bash and GNU coreutils (cut, tr, sed, sort, compgen).
#
# Author: ChatGPT
# Date: 2025-10-02
# Compatibility: Bash completion v2

# --- Helper: Obtain completion words with a fallback -----------------------

# Try to use the built‑in helper from bash-completion if available.
# If it fails or is missing, set cur and prev manually.
_ollama_run_completion() {
    local cur prev words cword

    # Use bash‑completion's helper if it exists.
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword || {
            # Fallback: manual extraction
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        }
    else
        # Manual extraction
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # --- Targeted triggering -------------------------------------------------
    # Ensure the command is `ollama` and the previous word is exactly `run`.
    if [[ ${COMP_WORDS[0]} != ollama ]] || [[ $prev != run ]]; then
        return
    fi

    # --- Parse available local models ---------------------------------------
    # Run `ollama list`, skip the header, collapse multiple spaces,
    # cut the first column (model name), and sort‑unique the list.
    # The output might look like:
    #   NAME                            ID              SIZE    MODIFIED
    #   llama3:latest                   a7320c749969    4.7 GB  3 weeks ago
    #   codellama:17b                   2b9b6e83e370    4.7 GB  2 months ago
    # We only want: llama3:latest codellama:17b codellama:32b
    local model_list
    model_list=$(ollama list 2>/dev/null | sed 1d | tr -s ' ' | cut -d' ' -f1 | sort -u)

    # If no models are found, abort completion.
    if [[ -z $model_list ]]; then
        COMPREPLY=()
        return
    fi

    # --- Contextual filtering -----------------------------------------------
    # Use compgen to filter the model list based on what the user has typed.
    # If the current word (`cur`) matches no model, COMPREPLY will be empty
    # and no fallback to filenames will occur.
    COMPREPLY=($(compgen -W "$model_list" -- "$cur"))
}

# Register the completion function for the `ollama` command.
complete -F _ollama_run_completion ollama

