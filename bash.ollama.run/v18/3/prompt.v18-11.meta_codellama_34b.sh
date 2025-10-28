
### Instructions

To create a bash completion script for the `ollama run <model>` command, follow these steps:

1. Define a function to handle the completions: `_ollama_completions()`
2. Check if we're in the right context by checking `COMP_WORDS[0]` and `COMP_WORDS[1]`. If not, return 0.
3. Handle colons with `_get_comp_words_by_ref -n :` to set `cur` and `prev`.
4. Parse the output of `ollama list` to get a list of models: `models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))`
5. Sort the list of models with `IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS`
6. Generate completions with `COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )`
7. Fix colons with `__ltrim_colon_completions "$cur"`
8. Register the completion function with `complete -F _ollama_completions ollama`

### Output Rules

When creating the script, follow these rules:

* ONLY BASH CODE – no extras
* Inline comments for key parts
* Handle edges (no ollama, no models)

### Checklist

To ensure that your completion script is complete and correct, check off each item in the following list:

* [ ] Correct index check
* [ ] COMP_CWORD check
* [ ] _get_comp_words_by_ref -n :
* [ ] __ltrim_colon_completions last
* [ ] Parse with tail/awk
* [ ] compgen -W (no manual)
* [ ] Sort
* [ ] Edges handled
* [ ] Works after ":"

