
Here is the final version of the code that completes model names for the `ollama run` command:
```bash
#!/bin/bash

_ollama_completions() {
  # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
  # makes the previous word "codellama" and the current word an empty string.
  # This breaks our context logic for completing model names.
  #
  # THE SOLUTION: We temporarily remove ':' from the word-breaking characters
  # and use a helper function to re-parse the command line with our new rule.

  # 1. Save the original word break characters.
  local _old_wb=${COMP_WORDBREAKS}
  # 2. Modify COMP_WORDBREAKS to remove the colon.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
  # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
  #    The `-n :` option tells it to NOT use the colon as a separator.
  _get_comp_words_by_ref -n : cur prev
  # 4. Restore the original word breaks immediately to avoid side-effects.
  COMP_WORDBREAKS=${_old_wb}

  if [[ "$prev" == "run" ]]; then
    local models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi
}
complete -F _ollama_completions ollama
```
This script defines a function `_ollama_completions` that is called by the `complete` command to provide completion suggestions for the `ollama run` subcommand. The function uses the `_get_comp_words_by_ref` helper function to re-parse the command line with a modified word break character, which allows it to handle colons correctly in model names. The script also registers the `_ollama_completions` function as the completion for the `ollama run` subcommand using the `complete -F` command.

You can save this code to a file (e.g., `ollama-run-completion.sh`) and source it in your `.bashrc` file or use it directly in your terminal session.

