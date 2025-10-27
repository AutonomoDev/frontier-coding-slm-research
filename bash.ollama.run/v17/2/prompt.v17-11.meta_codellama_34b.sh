
This is a well-defined prompt for generating a bash completion script for the "ollama run" command. The goal is to ensure that the generated script is robust, efficient, and correctly handles model names containing colons.

The primary objective is to generate a single production-quality Bash completion script for the "ollama run" command. The core challenge is the colon problem, which causes Bash completions to fail with model names like "codellama:13b". To fix this, the prompt requires implementing a two-part solution that correctly parses and displays suggestions after a colon has been typed.

The implementation requirements are as follows:

1. The script must define a single function called "_ollama_completions" and the very first action inside the function must check if the command is "ollama run". If it's not, the function must return immediately to prevent interference with other commands and avoid falling back to filename completion.
2. Inside the "ollama run" logic block, implement the two-part colon fix described above. Provide clear comments explaining this block.
3. Check if the "ollama" command is available on the system using "command -v ollama &>/dev/null". If it's not, exit immediately.
4. Fetch the list of models by running "ollama list" and parse the output to extract only the first column (the model name) using "awk 'NR>1 {print $1}'".
5. Use "compgen -W "<list_of_models>" -- "$cur"" to generate completion suggestions for the current word ("$cur"). Store the result in the "COMPREPLY" array. As the final step before the function ends, call "\_\_ltrim_colon_completions "$cur".
6. Register the completion function for the "ollama" command using "complete -F _ollama_completions ollama".

The output format must be a single, contiguous block of Bash code with detailed inline comments to explain complex parts, especially the context check and the colon-handling logic. The generated script must consist only of Bash code and its internal comments.

To ensure that the generated script meets all the requirements, a final verification checklist is provided:

*   Check "COMP_WORDS[1]" to confirm the subcommand is "run" and exit otherwise.
*   Implement the "COMP_WORDBREAKS" modification and restoration.
*   Use "\_get_comp_words_by_ref -n :" to get "cur" and "prev".
*   Parse "ollama list" output correctly, skipping the header.
*   Call "\_\_ltrim_colon_completions "$cur"" as the last step after setting "COMPREPLY".
*   Consist of only Bash code and its internal comments.

