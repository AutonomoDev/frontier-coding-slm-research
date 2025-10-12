_ollama_completions() {
    # Array Index Check (CRITICAL)
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    # Handle Colons
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama exists
    command -v ollama &>/dev/null || { COMPREPLY=(); return; }

    # Parse Models from "ollama list" output
    models=()
    while IFS='' read -r line; do
        [[ "$line" =~ ^NAME ]] && continue  # skip header
        model_name="${line%% *}"            # extract first column (model name)
        models+=("$model_name")
    done < <(ollama list 2>/dev/null)

    # Generate Completions
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Fix Colon Display (MANDATORY)
    __ltrim_colon_completions "$cur"
} && complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script should be production-ready and robust. It checks for the specific command `ollama run`, properly handles colons in model names, parses `ollama list` output correctly, and gracefully handles missing `ollama` command.
