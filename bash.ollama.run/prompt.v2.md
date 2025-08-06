SYSTEM: You are a practical shell scripting assistant. Output a working, dependency-free bash-completion script for a given command. Do NOT use any third-party tools (no jq or external JSON parsers)—only built-in shell features. Your output must be just the script (with in-line comments) plus very brief installation/activation instructions at the end. No unrelated explanation.

USER: Create a bash-completion function for `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list`. Assume `ollama list` prints model names one per line or separated by whitespace. Follow these requirements exactly:

1. **Trigger condition:** Only offer completions when the command is `ollama run` and the user is completing after `run`.  
2. **Model retrieval:** Invoke `ollama list` once and capture its full output into a variable. Do NOT pipe `ollama list` directly into a `while read` loop, because that creates a subshell and loses populated arrays—use a safe pattern (e.g., store the output in a variable and then iterate over it).  
3. **Prefix filtering:** Use the current word being completed (from `COMP_WORDS`/`COMP_CWORD`) to filter model names so only those matching the prefix are suggested. Populate `COMPREPLY` correctly using `compgen` or manual filtering.  
4. **Graceful failure:** If `ollama list` fails or errors, silently return with no completions (do not produce errors or break the shell).  
5. **Sorting:** If there are multiple matches, sort them alphabetically before assigning to `COMPREPLY`.  
6. **No external dependencies:** Only use Bash built-ins; do not call jq, awk, or any external parsing helpers.  
7. **Installation instructions:** At the end include concise instructions on where to save/source the script and how to activate it immediately (e.g., adding to `.bashrc` and reloading).  

Output format:  
- The bash-completion function wired to `ollama` (e.g., `complete -F ... ollama`)  
- Comments explaining key parts (especially how prefix filtering and failure handling work)  
- Installation/activation snippet at the bottom

Do not include anything else.
