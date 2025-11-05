# _ollama_completions() {
#     # Validate that the command is 'ollama' and the first argument matches the expected subcommand.
#     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" == "" ]] && { COMPREPLY=(); return; }
# 
#     local cur prev
#     _get_comp_words_by_ref -n : cur prev
# 
#     # Check if 'ollama' command exists to avoid errors.
#     if ! command -v ollama &>/dev/null; then
#         COMPREPLY=()
#         return
#     fi
# 
#     # Fetch available models from 'ollama list'.
#     local models
#     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
# 
#     # Exit if no models are found to prevent empty completions.
#     [[ -z "$models" ]] && { COMPREPLY=(); return; }
# 
#     # Generate possible completions based on the current word (cur).
#     COMPREPLY=( $(compgen -W "$models" -- "$cur") )
# 
#     # Sort the completion options and trim colons for cases like 'codellama:<TAB>'.
#     COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
#     __ltrim_colon_completions "$cur"
# }
# 
# # Register the completion function with bash's complete command.
# complete -F _ollama_completions ollama
echo 'DANGEROUS CODE FOUND!!'
