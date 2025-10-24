SYSTEM: You are a practical shell completion engineer. Output only a working, dependency-free bash-completion script (with concise inline comments) plus very brief installation/activation instructions. No unrelated explanation.

USER: Write a bash-completion function for `ollama run <model>` that meets all of these requirements:

1. **Triggering:** The completion must activate only when the user is completing the model argument after typing `ollama run`. It should work even if extra whitespace or other benign variations exist; the simplest reliable check is that the previous word is `run` and the command is `ollama`. Do not fail if there are more than two words in COMP_WORDS—only care that what’s being completed follows `run`.

2. **Model list retrieval:** Run `ollama list` exactly once and capture its full output into a variable. **Do not** pipe `ollama list` into a `while read` loop directly (because that creates a subshell and loses array contents). Instead, store output in a variable and then iterate over that variable safely.

3. **Prefix filtering:** Use the current word being completed (from `COMP_WORDS`/`COMP_CWORD`) as the prefix and include only model names that start with that prefix. Do **not** use hacks like prepending and stripping the prefix; perform a straightforward match, e.g., `[[ $model == "$cur"* ]]`.

4. **Sorting:** If there are multiple matching models, sort them alphabetically before assigning to `COMPREPLY`.

5. **Populate COMPREPLY correctly:** Either build `COMPREPLY` manually from filtered & sorted results or use `compgen -W ... -- "$cur"` on a prepared, alphabetically sorted list. The result must be valid Bash completion suggestions.

6. **Graceful failure:** If `ollama list` fails or returns empty, return without error and provide no completions.

7. **No external dependencies:** Use only Bash built-ins and GNU coreutils (sort, etc). Assume LINUX support only. Do not assume non-standard helpers are available. If you use `_get_comp_words_by_ref`, include a fallback that manually sets `cur` and `prev` from `COMP_WORDS`/`COMP_CWORD` if `_get_comp_words_by_ref` is missing or fails.

8. **Wiring:** Attach the function to `ollama` so that typing `ollama run <Tab>` triggers it.

9. **Installation instructions:** At the end include a minimal example of where to save or source the script and how to activate it immediately (e.g., add a `source` line to `.bashrc` and reload).

Output: Only the complete script with comments and the installation snippet. Do not include anything else.
