### **TASK: Produce a Fully-Working Bash Completion Function for `ollama`**

Generate a Bash function named **\_ollama\_completions** that implements tab-completion for the `ollama` CLI.
All of the ocde must be inside this function.

At the end, register it with:

```
complete -F _ollama_completions ollama
```

No markdown. No code fences. Output raw Bash.

---

# **1. SUBCOMMAND GROUPS (ABSOLUTE TRUTH TABLE)**

### **A. Commands requiring `<MODEL>` completion (Group 1)**

Use *exactly* the model-completion algorithm described in Section 3 for:

```
show  run  stop  push  cp  rm
```

**Special rule for `stop`:**
Model list must come from `ollama ps` instead of `ollama list`.

---

### **B. Commands with flags (Group 2)**

Flags ALWAYS come *after the model* (if applicable).
When `cur` begins with `-`, you MUST provide the flags:

| Command  | Flags                                                                           |
| -------- | ------------------------------------------------------------------------------- |
| `create` | `--file -f --quantize -q`                                                       |
| `pull`   | `--insecure`                                                                    |
| `run`    | `--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose` |
| `show`   | `--license --modefile --parameters --system --template --verbose`               |

Notes:
• `pull` has **flags only**, no model completion.
• `create` uses *model completion first*, then flags.

---

### **C. Commands with NO argument completion (Group 3)**

These must return **empty completion**:

```
serve  start  signin  signout  list  ls  ps  help
```

---

# **2. TOP-LEVEL COMPLETION RULE**

If the previous token is `ollama`, you MUST return the full list of subcommands:

```
show run stop push cp rm create pull serve start signin signout list ls ps help
```

---

# **3. REQUIRED MODEL-COMPLETION IMPLEMENTATION (STRICT TEMPLATE)**

For every Group-1 command *except `stop`*, and for the model-completion half of `run`, `show`, and `create`, you MUST use exactly the following logic — verbatim and in this order:

**Step A — Extract**

```
local cur prev
_get_comp_words_by_ref -n : cur prev
```

**Step B — Fetch Models**

```
if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
local models
models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
[[ -z "$models" ]] && { COMPREPLY=(); return; }
```

**Step C — Generate**

```
COMPREPLY=($(compgen -W "$models" -- "$cur"))
```

**Step D — Sort + Trim**

```
COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
__ltrim_colon_completions "$cur"
```

---

# **4. SPECIAL CASE — STOP MODEL COMPLETION**

`stop` must use the **same steps A–D**, except:

```
models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
```

---

# **5. FUNCTION SHAPE REQUIREMENT**

Your `_ollama_completions` function MUST:

1. Begin by calling `_get_comp_words_by_ref -n : cur prev words cword`
2. Extract subcommand as `words[1]`
3. Use a **single `case` statement** switching on the subcommand
4. In each arm, follow the exact required logic and **no fallback paths**
5. Return immediately after producing a completion set

---

# **6. HARD CONSTRAINTS (NON-NEGOTIABLE)**

❌ **Do NOT** use arrays to store the model list (`models` MUST be a string).
❌ **Do NOT** change or reorder Steps A–D.
❌ **Do NOT** add alternative completion strategies.
❌ **Do NOT** add error handling beyond what is shown.
❌ **Do NOT** check for the existence of helper functions.
❌ **Do NOT** sort models before compgen.
❌ **Do NOT** output anything except raw Bash code.

✔️ **Inline comments** are allowed but must be brief.

---

# **7. FINAL OUTPUT**

Only raw Bash.
No markdown.
No explanation.
No code fences.
Exactly one function + one `complete` registration.

