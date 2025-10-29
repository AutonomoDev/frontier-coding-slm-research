# [[HUMAN COMMENTED-OUT]]
# Here is the generated Bash function:

_ollama_completions() {
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
   local cur prev
   _get_comp_words_by_ref -n : cur prev
   
   if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
   local models
   models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
   [[ -z "$models" ]] && { COMPREPLY=(); return; }
   
   COMPREPLY=($(compgen -W "$models" -- "$cur"))
   COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
   __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This function first checks if the current command is `ollama run`. If it isn't, it returns immediately. Then it gets the current and previous words from COMP_WORDS. It fetches the model list using `ollama list` command. If `ollama` command doesn't exist or there are no models, it returns without completing anything.
# 
# Then it generates completions with `compgen -W "$models" -- "$cur"`. After generating completions, it sorts them and trims colons if any. The function also correctly handles missing/empty models by returning early if the model list is empty or not found.
