SYSTEM: You are an expert in Bash scripting, specifically the `bash-completion` framework. Your task is to create a robust and correct Bash completion script for the `ollama run` command.

Your solution must be a self-contained Bash script that can be sourced (e.g., `source my_script.sh`) to enable the functionality.

**Core Requirement:**
The script must provide autocompletion suggestions for model names when a user types `ollama run ` and presses the `<TAB>` key.

**How to Get the Data:**
The list of available local models is obtained by running the command `ollama list`. You must parse the output of this command.

A typical output of `ollama list` looks like this:
```
NAME                            ID              SIZE    MODIFIED
llama3:latest                   a7320c749969    4.7 GB  3 weeks ago
codellama:7b-instruct           2b9b6e83e370    4.7 GB  2 months ago
deepseek-coder-v2:16b-lite      278b4081325b    9.3 GB  2 weeks ago
```

**--- STRICT REQUIREMENTS ---**

1.  **Targeted Triggering:** The completion logic **MUST** only activate for the word immediately following the `run` subcommand. It should not attempt to complete `ollama` itself or any other subcommand. Check that the second word (`${COMP_WORDS[1]}`) is exactly `run`.

2.  **Precise Parsing:** You **MUST** parse the output of `ollama list`.
    *   Extract **only the model names** from the first column (e.g., `llama3:latest`, `codellama:7b-instruct`).
    *   You **MUST** skip the header line of the output (the line that starts with `NAME`).
    *   Use a standard and reliable tool like `awk '{print $1}'` or `cut` for this parsing.

3.  **Contextual Filtering:** The suggestions provided **MUST** be filtered based on the word the user is currently typing. For example, if the user types `ollama run co<TAB>`, only models starting with `co` should be suggested.

4.  **No Filename Fallback:** If the word being completed does not match any available model, you **MUST NOT** fall back to suggesting filenames from the current directory. The completion should simply provide no suggestions.

5.  **Unique Suggestions:** The final list of completion suggestions **MUST NOT** contain duplicate entries.

6.  **Standard Bash:** The entire script must use valid, standard Bash syntax compatible with the `bash-completion` v2 framework. Use standard variables like `COMP_WORDS`, `COMP_CWORD`, and `COMPREPLY`.

**--- AVOID THESE COMMON MISTAKES (ANTI-PATTERNS) ---**

*   **DON'T** just print the raw, unfiltered output of `ollama list` to the user.
*   **DON'T** offer completions for parts of the `ollama list` output that are not model names (e.g., hashes, sizes, modification dates).
*   **DON'T** use `_get_comp_words_by_ref` or other functions that may not be universally available. Stick to the core `COMP_*` variables.
*   **DON'T** generate a script that causes errors like `unknown argument` by trying to complete the wrong word in the command line.
*   **DON'T** produce a script that enters an infinite loop.

**--- EXAMPLE OF CORRECT BEHAVIOR ---**

Given the `ollama list` output from above, here is how the script should behave:

1.  User types `ollama run ` and presses `<TAB>`:
    ```bash
    $ ollama run <TAB>
    llama3:latest  codellama:7b-instruct  deepseek-coder-v2:16b-lite
    ```

2.  User types `ollama run l` and presses `<TAB>`:
    ```bash
    $ ollama run l<TAB>
    llama3:latest
    ```

3.  User types `ollama run cod` and presses `<TAB>`:
    ```bash
    $ ollama run cod<TAB>
    codellama:7b-instruct
    ```

4.  User types `ollama run xyz` and presses `<TAB>`:
    ```bash
    $ ollama run xyz<TAB>
    # (No output, no suggestions, no errors)
    ```

Now, generate the complete bash completion script that meets all these requirements.

Output: Only the complete script with comments. Do not include anything else.
