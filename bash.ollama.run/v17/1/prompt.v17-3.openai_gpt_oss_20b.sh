#!/usr/bin/env bash

# Bash completion script for the `ollama run` command.
# It provides model name completions, correctly handling names that contain a colon (:).

# ------------------------------------------------------------------
# _ollama_completions
#
# This function is the single entry point for the completion logic.
# It is registered with the `complete` builtin for the `ollama` command.
# ------------------------------------------------------------------
_ollama_completions() {
    # ------------------------------------------------------------------
    # 1. Context check: only run when the subcommand is `run`.
    #    This prevents the completion from interfering with other `ollama`
    #    subcommands or causing filename completion to trigger.
    # ------------------------------------------------------------------
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # ------------------------------------------------------------------
    # 2. Colon‑handling fix:
    #    Bash splits words on `:` by default, which breaks model names like
    #    "codellama:13b".  We temporarily remove the colon from
    #    COMP_WORDBREAKS, re‑parse the command line, and then restore the
    #    original value.  This ensures $cur and $prev are parsed correctly.
    # ------------------------------------------------------------------
    local orig_breaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
    # Re‑parse words, excluding any colons, and store the current and previous words.
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS="$orig_breaks"

    # ------------------------------------------------------------------
    # 3. Dynamic model list generation.
    #    Check that the `ollama` binary exists before attempting to query it.
    # ------------------------------------------------------------------
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Retrieve the list of models: skip header line and keep the first column.
    # Example output of `ollama list`:
    #   NAME          ID          ...
    #   codellama:13b <hash>
    #   gpt-4o       <hash>
    # We want: codellama:13b gpt-4o ...
    local model_list
    model_list=$(ollama list | awk 'NR>1 {print $1}')

    # ------------------------------------------------------------------
    # 4. Generate completions for the current word ($cur).
    #    The -W option supplies the words to match against.
    # ------------------------------------------------------------------
    COMPREPLY=()
    if [[ -n "$model_list" ]]; then
        COMPREPLY=( $(compgen -W "$model_list" -- "$cur") )
    fi

    # ------------------------------------------------------------------
    # 5. Final colon‑display fix: trim the colon from displayed completions.
    #    This ensures that, for example, "codellama:" completes to
    #    "codellama:13b" rather than displaying "codellama:codellama:13b".
    # ------------------------------------------------------------------
    __ltrim_colon_completions "$cur"
}

# ------------------------------------------------------------------
# Register the completion function for the `ollama` command.
# ------------------------------------------------------------------
complete -F _ollama_completions ollama
