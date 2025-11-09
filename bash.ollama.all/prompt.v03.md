### **Prompt: Generate a Bash Completion Script for `ollama`**

Your task is to generate a single, complete Bash function named `_ollama_completions` that provides tab completion for the `ollama` command line tool.

---

### **Commands to Support**

Group the commands by their completion behavior:

1.  **Commands requiring `<MODEL>` completion:**
    *   `show`, `run`, `stop`, `push`, `cp`, `rm`

2.  **Command with special flag completion:**
    Flags are ALWAYS after the model.
    * `create` (flags: `--file`, `-f`, `--quantize`, `-q`)
    * `pull` (flags: `--insecure`)
    * `run` (flags: `--format`, `--hidethinking`, `--insecure`, `--keepalive`, `--nowordwrap`, `--think`, `--verbose`)
    * `show` (flags: `--license`, `--modefile`, `--parameters`, `--system`, `--template`, `--verbose`)

3.  **Commands with no argument completion:**
    *   `serve`, `start`, `pull`, `signin`, `signout`, `list`, `ls`, `ps`, `help`

4. For `stop`, run `ollama ps` for models to complete, which gives
```
NAME           ID              SIZE      PROCESSOR    CONTEXT    UNTIL
gemma3:270m    e7d36fb2c3b3    584 MB    100% GPU     4096       4 minutes from now
```



---

### **Functional Requirements**

The ollama command is guaranteed to exist.

The generated script must follow this exact structure and logic:

1.  **Main Function:** The entire logic must be within a single function named `_ollama_completions`.

2.  **Use a `case` Statement:** Use a `case` statement that switches on the subcommand (e.g., `run`, `create`) to handle the different completion types.

3.  **Top-Level Completion:**
    *   If the previous word is `ollama`, provide a list of all subcommands as completions.

4.  **Model Name Completion Logic (Exact Steps):**
    *   For the commands listed in Group 1 (`show`, `run`, etc.), you **must** use the following precise implementation to fetch and display model names. **Do not deviate.**

    *   **Step A: Extract Word Info**
        ```bash
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        ```
    *   **Step B: Fetch Models** (Handle missing `ollama` command and empty model list)
        ```bash
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        ```
    *   **Step C: Generate Completions**
        ```bash
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        ```
    *   **Step D: Sort and Trim**
        ```bash
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        ```

### **Constraints (What to Avoid)**

*   **DO NOT** use arrays to store the list of models (`models` must be a string).
*   **DO NOT** add fallback logic.
*   **DO NOT** check for the existence of `_get_comp_words_by_ref` or `__ltrim_colon_completions`.
*   **DO NOT** sort the models before passing them to `compgen`.

### **Final Output Rules**

*   Output **only the raw Bash code**.
*   Do not include any markdown, explanations, or fences (like ` ```bash `).
*   Add brief, inline comments to explain key parts of the code.
*   Register the completion function at the end with `complete -F _ollama_completions ollama`.
