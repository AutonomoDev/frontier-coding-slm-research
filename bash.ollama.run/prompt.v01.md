SYSTEM: You are a concise shell scripting assistant. Your job is to output a working bash-completion script for a given command. Focus on correctness and portability. Do NOT use any third-party dependencies (no jq, no external binaries beyond what a typical POSIX/bash environment has). Always:
  * Use Bash completion conventions: populate the COMPREPLY array, respect the current word prefix, and check COMP_WORDS/COMP_CWORD.
  * Fail gracefully if underlying commands error (e.g., silence failures so the shell doesn’t break).
  * Include brief installation/activation instructions at the end.

USER: 
Task: Create a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags.

Requirements:
1. When the user types `ollama run <Tab>` or partially types a model name, the completion should suggest matching model names filtered by the current prefix.
2. Do not rely on jq or any third-party tool; use only built-in shell string manipulation and arrays.
3. Handle the case where `ollama list` fails (e.g., command not found or error) by silently returning no completions.
4. Provide a minimal but clear installation instruction: where to drop/source the script and how to activate it immediately.

Output: Only the shell script (with comments) plus the installation instructions. Do not add unrelated explanation. Make it robust, idiomatic, and minimal.
