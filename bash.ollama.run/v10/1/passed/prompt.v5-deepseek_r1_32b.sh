#Thinking...
#Alright, I need to create a robust Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which Bash treats as word breaks by default. Let me break down how I should approach this.
#
#First, I'll define a function named `_ollama_completions`. This function will handle completions specifically for the `ollama` command.
#
#Inside the function, the first step is to check if the subcommand is "run". If not, I'll return early to avoid unnecessary processing. So, I'll look at `COMP_WORDS[1]` since the first word is usually the command itself (`ollama`).
#
#Next, I need to handle the colons in model names. By default, Bash splits words on colons, which disrupts the parsing of model names like `codellama:13b`. To fix this, I'll temporarily remove the colon from `COMP_WORDBREAKS`. I'll save the original value so I can restore it later.
#
#After modifying `COMP_WORDBREAKS`, I'll use `_get_comp_words_by_ref -n : cur prev` to re-parse the command line. This ensures that colons are not treated as word breaks, allowing me to correctly capture the current and previous words.
#
#It's crucial to immediately restore the original `COMP_WORDBREAKS` after parsing to prevent affecting other parts of the script or shell session.
#
#Now, if the previous word is "run", I'll retrieve the model names. Using `ollama list`, I can extract the first column starting from the second line (to skip headers) with `awk 'NR>1 {print $1}'`. This gives me a list of models.
#
#I'll then use `compgen -W "$models" -- "$cur"` to generate possible completions. This command takes the list of models and the current word being typed, producing the appropriate suggestions.
#
#Finally, I need to register this completion function with Bash using `complete -F _ollama_completions ollama`. This ensures that whenever the user types `ollama` followed by a space, the completions are triggered.
#
#I'll make sure all variables are properly quoted to prevent word splitting and that the script is robust against errors. The inline comments will explain each step clearly for maintainability.
#...done thinking.

# Bash completion function for ollama run command with model name completion handling colons
_ollama_completions() {
    # Check if the subcommand is 'run'
    local cur prev cmd
    cmd=${COMP_WORDS[1]}
    if [[ "$cmd" != "run" ]]; then
        return 0
    fi

    # Save original word breaks and remove colon from them
    local original_comp_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Reparse command line with colons handled properly
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks immediately after re-parsing
    COMP_WORDBREAKS=$original_comp_wordbreaks

    # If previous word is 'run', generate model completions
    if [[ "$prev" == "run" ]]; then
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        return 0
    fi

    return 0
}

# Register the completion function with bash-completion framework
complete -F _ollama_completions ollama
