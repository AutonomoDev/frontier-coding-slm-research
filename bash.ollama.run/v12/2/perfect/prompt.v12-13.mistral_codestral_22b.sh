# Bash completion script for the `ollama run` command.

_ollama_completions() {
 local cur prev models matches sorted_matches

 if ! _get_comp_words_by_ref -n : cur prev; then
   # Fallback: If _get_comp_words_by_ref is not available, use basic COMP_WORDS.
   cur="${COMP_WORDS[COMP_CWORD]}"
   prev="${COMP_WORDS[COMP_CWORD-1]}"
 fi

 # Check if the first word is "ollama" and the previous word is "run". If not, return early.
 if [[ ${COMP_WORDS[0]} != ollama || $prev != run ]]; then
   COMPREPLY=()
   return 0
 fi

 # Check if `ollama` command exists. If not, return early.
 if ! command -v ollama &> /dev/null; then
   COMPREPLY=()
   return 0
 fi

 while IFS= read -r line || [[ -n "$line" ]]; do
   # Skip header and empty lines. Extract only the model name (first column).
   if [[ $line != "NAME ID SIZE MODIFIED" && -n $line ]]; then
     model=$(echo "$line" | awk '{print $1}')
     [[ -n $model ]] && models+=("$model")
   fi
 done < <(ollama list 2>/dev/null)

 # If no models, return early.
 if [ ${#models[@]} == 0 ]; then
   COMPREPLY=()
   return 0
 fi

 for model in "${models[@]}"; do
   [[ $model = "$cur"* ]] && matches+=("$model")
 done

 # Sort the matches.
 sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

 COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

 # CRITICAL COLON FIX: This makes suggestions show correctly after colons.
 __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

