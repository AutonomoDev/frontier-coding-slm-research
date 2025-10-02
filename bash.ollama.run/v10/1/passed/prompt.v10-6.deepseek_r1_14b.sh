#Thinking...
#Alright, I need to create a robust Bash completion script for the `ollama run` command that dynamically completes model names from the output of `ollama list`. The main challenge is handling model names that contain colons, as Bash by default splits words on colons, causing issues with parsing.
#
#First, I should define a function named `_ollama_completions` to handle the completion logic. This function will be triggered during tab completion for the `ollama` command.
#
#Inside the function, I'll check if the first argument after `ollama` is "run". If not, there's nothing to do, so I'll return early.
#
#Next, I need to address the colon issue. By default, Bash splits words at colons, which messes up model names like `codellama:13b`. To handle this, I'll temporarily remove the colon from `COMP_WORDBREAKS`. This involves saving the original value, modifying it by removing colons using parameter expansion, re-parsing the command line with `_get_comp_words_by_ref`, and then restoring the original word breaks to avoid side effects.
#
#After handling the word breaks, I'll proceed with the completion logic. If the previous word is "run", I need to fetch the model names. I'll run `ollama list` and extract the first column starting from the second line using `awk`. This gives me all the model names available.
#
#Using `compgen -W`, I'll generate the possible completions based on the current cursor position (`$cur`). The models are passed as a space-separated string, so quoting is necessary to prevent word splitting.
#
#Finally, I'll register the completion function with `complete` for the `ollama` command. This ensures that whenever the user types `ollama`, the `_ollama_completions` function is called to provide the necessary completions.
#
#Throughout this process, I need to make sure that all variables are handled correctly, especially avoiding global modifications beyond what's necessary and ensuring proper quoting to handle spaces or special characters in model names.
#...done thinking.

# Bash completion script for ollama run command with colon-safe model name handling
# This script provides intelligent completions for ollama run <model> commands

_ollama_completions() {
    # Check if we're completing after the 'run' subcommand
    [[ ${COMP_WORDS[1]} != "run" ]] && return

    # Save original word break settings and remove colon to prevent word splitting
    local -r original_word_breaks="${COMP_WORDBREAKS}"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Reparse command line with colons treated as part of the words
    _get_comp_words_by_ref -n : cur prev

    # Restore word break settings after parsing
    [[ -n ${original_word_breaks} ]] && COMP_WORDBREAKS="${original_word_breaks}"

    # Only generate completions if previous word was 'run'
    if [[ "${prev}" == "run" ]]; then
        # Get list of available models from ollama list command
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions for the model names after 'run'
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register completion function for ollama command
complete -F _ollama_completions ollama

