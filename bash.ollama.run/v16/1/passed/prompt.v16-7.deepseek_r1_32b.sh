#Thinking...
#Okay, I need to generate a Bash completion script specifically for the command `ollama run`. The user provided detailed instructions and some critical bugs to avoid. Let me go through each step carefully.
#
#First, I should start by declaring the function `_ollama_completions()`. Inside this function, the first thing I must do is check if we're completing after "ollama run". This is crucial because if not, we shouldn't provide any completions. The indexing check should be exact: COMP_WORDS[0] must be "ollama" and COMP_WORDS[1] must be "run". If this isn't the case, I set COMPREPLY to an empty array and return.
#
#Next, handling the colon is important. By default, Bash treats colons as word breaks, which messes up completions when a model name includes a colon like "codellama:13b". To fix this, I need to temporarily remove the colon from COMP_WORDBREAKS. Then, reparse the words using `_get_comp_words_by_ref -n : cur prev` so that the current word (`cur`) correctly captures everything after `ollama run`, including any colons.
#
#After handling the colon, I check if the command `ollama` is available using `command -v ollama`. If it's not found, I set COMPREPLY to an empty array and return. This prevents errors when the command isn't installed.
#
#Now, I extract the model names from `ollama list`. Using `awk 'NR>1 {print $1}'` skips the header line and gets the first column, which contains the model names. Storing these in a variable called `models`, I then check if `models` is empty. If it is, again, set COMPREPLY to an empty array and return.
#
#The next step is generating the completions. Using `compgen -W "$models" -- "$cur"` filters the models that start with the current word being typed. This gives the possible completions. Then, I must call `__ltrim_colon_completions "$cur"` to ensure that after a colon, only the relevant suffixes are displayed. For example, if the user types "codellama:13b<tab>", it should suggest "13b" correctly.
#
#Finally, I register the completion function with `complete -F _ollama_completions ollama` so that Bash knows to use this function for completions when the command starts with `ollama`.
#
#I need to make sure all critical parts are included: exact indexing check, proper colon handling, reliable model extraction, setting COMPREPLY in all cases, and calling `__ltrim_colon_completions`. Also, the script should handle cases where ollama isn't installed or there are no models without crashing.
#
#Putting it all together, I structure each part step by step, ensuring that comments are minimal but explain critical steps. The final script is self-contained and ready for production use.
#...done thinking.

_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
    
    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}
    
    # Check if ollama available
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
    
    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    
    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }
    
    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    # Fix display after colons
    __ltrim_colon_completions "$cur"
    return 0
}

complete -F _ollama_completions ollama
