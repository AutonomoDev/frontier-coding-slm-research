Thinking...
We need to output a bash completion script following the constraints. We must generate a script that registers a function _ollama_run_completions for the command "ollama". The function should check if second word is "run" to trigger. But must also handle colon removal from COMP_WORDBREAKS to handle names with colon.

The steps: at start of function, store original COMP_WORDBREAKS; then modify; then _get_comp_words_by_ref -n : cur prev; then restore original COMP_WORDBREAKS.

We must ensure that the colon removal happens before subcommand check, as required.

We also need to parse ollama list. Use command: ollama list | awk 'NR>1{print $1}' . However need to handle spaces. Model names contain colon but no spaces. The first column is NAME. It may be preceded by spaces? But output shows columns separated by spaces. So awk 'NR>1 {print $1}'. Or use cut.

We'll gather options into an array: mapfile -t models < <(ollama list | awk 'NR>1{print $1}')

Then compgen -W "${models[*]}" -- "$cur"

But we must handle quotes etc. compgen expects words.

Also we need to use COMP_WORDS and COMP_CWORD. Use get_comp_words_by_ref? This is from programmable completion functions. We'll use _get_comp_words_by_ref -n : cur prev

Then check [[ "${COMP_WORDS[1]}" == "run" ]].

Also if cur is empty, we still want to offer suggestions. That's fine.

Need to set COMPREPLY accordingly.

Also need to use complete -F _ollama_run_completions ollama

Need to add comment lines.

Let's craft script:

#!/usr/bin/env bash
# Completion for ollama run

_ollama_run_completions() {
    local cur prev
    local -a models

    # Save original word breaks
    local orig_word_breaks="${COMP_WORDBREAKS}"
    # Remove colon from word breaks
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
    # Re-parse words, ignoring colons
    _get_comp_words_by_ref -n : cur prev
    # Restore original word breaks
    COMP_WORDBREAKS="${orig_word_breaks}"

    # Only proceed if second word is "run"
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Fetch model names
    mapfile -t models < <(ollama list 2>/dev/null | awk 'NR>1{print $1}')
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    return 0
}

complete -F _ollama_run_completions ollama

This should satisfy all points.

Make sure to comment. Output must be only script.

Let's produce final answer.
...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run` – dynamically lists available models
# and correctly handles model names that contain colons.

_ollama_run_completions() {
    local cur prev
    local -a models

    # Preserve the original word‑break set
    local orig_word_breaks="${COMP_WORDBREAKS}"
    # Temporarily remove ':' so that model names with colons aren't split
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
    # Re‑parse the current command line using the modified word breaks
    _get_comp_words_by_ref -n : cur prev
    # Restore the original word breaks immediately after parsing
    COMP_WORDBREAKS="${orig_word_breaks}"

    # Only activate when the subcommand is exactly 'run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Retrieve model names from `ollama list`, ignoring the header line
    mapfile -t models < <(ollama list 2>/dev/null | awk 'NR>1{print $1}')
    # Generate completions based on the current input
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
}

# Register the completion function for the `ollama` command
complete -F _ollama_run_completions ollama


