#Thinking...
#Alright, let's tackle this problem. The user wants a Bash completion script for the `ollama run` command that handles model names with colons correctly. By default, Bash splits words on colons, which messes up the parsing when models have colons.
#
#First, I need to create a function `_ollama_completions` that triggers only when the subcommand is `run`. So, I'll check if the previous word is "run".
#
#Next, I remember that the bash-completion framework has a helper function `_get_comp_words_by_ref`, which can re-parse the command line with modified word break rules. This seems crucial because it allows us to handle colons correctly.
#
#The plan is:
#1. Save the original `COMP_WORDBREAKS` variable.
#2. Remove the colon from `COMP_WORDBREAKS`.
#3. Use `_get_comp_words_by_ref -n : cur prev` to re-parse the current and previous words without treating colon as a word break.
#4. Restore `COMP_WORDBREAKS` after parsing.
#
#Then, I need to dynamically get model names from `ollama list`. Using `awk 'NR>1 {print $1}'` on the output of `ollama list` will extract just the model names.
#
#Finally, set up the completion using `complete -F _ollama_completions ollama` so that it only activates for the `run` subcommand. I'll add comments to explain each step clearly.
#...done thinking.

# Bash Completion Script for Ollama Run Command

# Function to handle model name completions for ollama run
_ollama_completions()
{
    # Only trigger completion for "ollama run" command
    if [[ "$prev" == "run" ]]; then
        # Save original word break characters and remove colon to prevent splitting
        local _old_wb=${COMP_WORDBREAKS}
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

        # Use helper function to correctly parse current and previous words without treating colon as separator
        _get_comp_words_by_ref -n : cur prev

        # Restore original word break characters to avoid affecting other completions
        COMP_WORDBREAKS=${_old_wb}

        # Extract model names from ollama list command output
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions based on extracted model names and current word
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register completion function for ollama command with run subcommand focus
complete -F _ollama_completions ollama
