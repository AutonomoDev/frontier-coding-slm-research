Thinking...
We need to produce a bash completion script as per requirements. Let's design.

Script: function _ollama_run_completions.

Inside function:

- Preserve original COMP_WORDBREAKS into a variable old_comp_wordbreaks.

- Remove colon from COMP_WORDBREAKS: e.g., `COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"`.

- Then call `_get_comp_words_by_ref -n : cur prev` to reparse words ignoring colon.

- Restore original COMP_WORDBREAKS: `COMP_WORDBREAKS="$old_comp_wordbreaks"`.

After that, check if second word is "run": `[[ "${COMP_WORDS[1]}" == "run" ]]`. But careful: `COMP_WORDS[1]` may be undefined? But should be.

If not, return.

If yes: fetch models.

We need to parse output: run `ollama list` - get first column. Use e.g., `ollama list | awk 'NR>1 {print $1}'`. That would ignore header.

But the list command may print header row with multiple spaces and maybe `#` etc. But okay.

So we can get: `models=$(ollama list --quiet 2>/dev/null | awk 'NR>1{print $1}')`? Wait `ollama list` may have a quiet mode? I'm not sure. We just call `ollama list` and parse.

But there might be error: if `ollama` not found. Should handle.

We can do:

```
local models
models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
```

Then we need to use `COMPREPLY=($(compgen -W "$models" -- "$cur"))`.

We need to declare local variables.

Complete function:

```
_ollama_run_completions()
{
    local cur prev words cword
    # Save original wordbreaks
    local o_wordbreaks="$COMP_WORDBREAKS"
    # Remove colon
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
    # Re-parse words
    _get_comp_words_by_ref -n : cur prev
    # Restore
    COMP_WORDBREAKS="$o_wordbreaks"

    # Only for run subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Get models list
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}
complete -F _ollama_run_completions ollama
```

But we need to ensure `_get_comp_words_by_ref` is defined; it's part of bash-completion package. So we rely on it.

Also ensure function is defined before complete call.

Also we might want to guard against no models: then COMPREPLY empty.

Edge: if command is `ollama run` with no args: `cur` will be empty and we want to provide model names. This will work.

Also if cur contains colon, we removed colon from wordbreaks, so `_get_comp_words_by_ref` splits correctly.

Also we must handle case when `cur` might be a partial string with colon, e.g., `codellama:`.

Now final script: no extra text.

Let's produce.
...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run` that handles model names with colons

_ollama_run_completions()
{
    local cur prev
    # Preserve original wordbreaks
    local _orig_comp_wordbreaks="$COMP_WORDBREAKS"
    # Temporarily remove colon from wordbreaks
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"
    # Re-parse words so that colons are not treated as delimiters
    _get_comp_words_by_ref -n : cur prev
    # Restore original wordbreaks
    COMP_WORDBREAKS="$_orig_comp_wordbreaks"

    # Activate only for the `run` subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Dynamically fetch available model names
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate completion suggestions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

complete -F _ollama_run_completions ollama


