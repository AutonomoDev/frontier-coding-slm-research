```bash
#!/bin/bash

_ollama_run_completions() {
  # Temporarily remove ':' from COMP_WORDBREAKS to handle colon-containing model names
  OLD_COMP_WORDBREAKS="${COMP_WORDBREAKS}"
  COMP_WORDBREAKS=$(echo "$COMP_WORDBREAKS" | sed "s/:/ /g")

  # Re-parse the current and previous words with re-split on ':'
  _get_comp_words_by_ref -n : cur prev

  # Restore original COMP_WORDBREAKS
  COMP_WORDBREAKS="${OLD_COMP_WORDBREAKS}"

  # Check if the second word is exactly "run"
  [[ "${COMP_WORDS[1]}" == "run" ]] || return 0

  # Get list of models from 'ollama list' command
  MODELS=$(ollama list | sed -n '/^NAME/,$ p' | sed '1d')

  # Generate a list of model names by extracting first column (skipping the header line)
  for MODEL in $MODELS; do echo "${MODEL%% *}"; done
}

complete -F _ollama_run_completions ollama
```
This script should work as expected, dynamically fetching model names from `ollama list` and correctly handling model names containing colons.

