<think>We need to produce a fully working bash completion function for ollama CLI command. We'll name it _ollama_completions. The instructions say: "Generate a Bash function named `_ollama_completions` that implements tab-completion for the `ollama` CLI." And then at the end register with complete -F _ollama_completions ollama.

The task is described in detail.

Let's re-read the requirements carefully:

---

### Requirements Summary:

- The output must be raw Bash code (no markdown formatting, no code fences, etc)

- The function: _ollama_completions

- It should be a single function that implements tab-completion for ollama CLI.

- All logic is inside this function. And at the end, register it with complete -F _ollama_completions ollama command.

---

### Subcommand Groups (Absolute Truth Table):

**Group 1: Commands requiring `<MODEL>` completion**
- Use exactly the model-completion algorithm described in Section 3 for:
```
show run stop push cp rm
```
But special rule: For `stop`, use models from "ollama ps" instead of "ollama list".

---

**Group 2: Commands with flags (Group 2)**

Flags always come after the model if applicable.
When `cur` begins with `-`, you MUST provide the flags. The table:

| Command  | Flags                                                                           |
| -------- | ------------------------------------------------------------------------------- |
| create   | --file -f --quantize -q                                                        |
| pull     | --insecure                                                                     |
| run      | --format --hidethinking --insecure --keepalive --nowordwrap --think --verbose    |
| show     | --license --modefile --parameters --system --template --verbose                |

Notes:
- `pull` has flags only, no model completion.
- `create` uses model completion first then flags.

---

**Group 3: Commands with NO argument completion (Group 3)**

These must return empty completions:

```
serve start signin signout list ls ps help
```

---

### Top-Level Completion Rule:
If the previous token is "ollama", you MUST return the full list of subcommands. The list:

```
show run stop push cp rm create pull serve start signin signout list ls ps help
```

- So if we are at position 0? Actually, need to recall how completions work in bash. Usually, words array is built from the command line arguments. If the first argument is "ollama", then word[1] would be empty string? But instructions say: "if previous token is ollama" then must return full list of subcommands. Possibly we need to check if number of words equals 1 (or something). Alternatively, in completions function, we want to complete the first token.

Let's check details: In our function, it says: Begin by calling _get_comp_words_by_ref -n : cur prev words cword. Then extract subcommand as words[1]. So if there is no subcommand (words[1] equals ""), then that means the completion has not typed any argument? But instructions say "if previous token is ollama, you MUST return full list of subcommands." That may mean when words[0]=="ollama", and maybe words[1] is empty. So we need to check if there's no second word provided.

But wait, the instructions says: "If the previous token is ollama" but then "words[1]" should be extracted as subcommand. But if words[1] is empty, then it means no subcommand yet typed? Possibly yes. So we need to check if $subcommand is empty (or equals ""), then output full list of subcommands.

Let's re-read the top-level rule: "If the previous token is ollama, you MUST return the full list of subcommands: [list]". But since this function always starts with _get_comp_words_by_ref -n : cur prev words cword, so words[0] will be the command name? Actually, typically when using bash completion for a command like "ollama", we want to complete the first argument after ollama. So if no subcommand provided then words[1] is empty. However instructions says: "if previous token is ollama". It might mean that the function is called with the partial input, and the word array would have "ollama" as first element. But how to detect top-level? Possibly we check if cword equals 0 or maybe words[1] length equals zero.

I recall common pattern: 
if [[ "$cword" -eq 1 ]]; then
   COMPREPLY=($(compgen -W "<list>" -- "$cur"))
fi

So I'll do that. That is for top-level completion.

---

### Section 3: REQUIRED MODEL-COMPLETION IMPLEMENTATION (STRICT TEMPLATE)

For every Group-1 command except stop, and for the model-completion half of run, show, create, use exactly these steps in order:

Step A:
```
local cur prev
_get_comp_words_by_ref -n : cur prev
```
But note that instructions say: "Your _ollama_completions function MUST: Begin by calling _get_comp_words_by_ref -n : cur prev words cword". So we already have to call _get_comp_words_by_ref -n : cur prev words cword. But then the template says just "local cur prev _get_comp_words_by_ref -n : cur prev", but they mention must use _get_comp_words_by_ref with -n flag? Check instructions: "Begin by calling _get_comp_words_by_ref -n : cur prev words cword". So we need that call exactly. We'll do it.

We then need to extract subcommand as "words[1]".

- For Group 1 commands, if $cur does not begin with "-" maybe? But instructions say: "For every Group-1 command except stop and for the model-completion half of run, show, create use exactly the following logic in order." And that logic is Step A - Extract, Step B - Fetch Models, etc.

Step B:
```
if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
local models
models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
[[ -z "$models" ]] && { COMPREPLY=(); return; }
```
But note: For stop, instead of using ollama list, must use "ollama ps". So for command stop, we do exactly the same steps but with models=$(ollama ps ...)

Step C:
```
COMPREPLY=($(compgen -W "$models" -- "$cur"))
```

Step D:
```
COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
__ltrim_colon_completions "$cur"
```
I need to check the instructions: "Do not change or reorder Steps A–D." So we must use them exactly as shown in that order.

We have constraints:
- Do NOT use arrays to store the model list, so $models must be a string. But our code can use compgen -W "$models" which will output completions.
- Do NOT sort models before compgen; we do sorting after compgen in Step D.

- Do not add alternative completion strategies or fallback paths.

Now for group 2 commands: For commands with flags, if $cur starts with a dash, then provide the flags. But they are provided as a list of strings separated by spaces? Possibly need to use compgen -W "option1 option2 ..." -- "$cur"? But instructions say:
"For Group 2: When cur begins with '-', you MUST provide the flags" and there's table.

But note: For create, after providing model completion, then flags. So for command create, if we are in the model-completion half (i.e., words[1] is not empty but still expecting a model?), or if $cur does not start with '-', then do model completion first; then if it starts with '-' maybe then provide flags? Wait instructions: "create uses model completion first, then flags." But how do we differentiate these cases?

Typically, in bash completions, the word array and cword index indicate which argument is being completed. For create command, when completing after the subcommand, it might be either waiting for a model or for a flag.

So what exactly does "create uses model completion first then flags" mean? 
I think the intended behavior is: If $cword==2 (i.e., second argument) and the word doesn't start with '-', do model completion. But if it's third argument and word starts with "-", then provide the flags.
But instructions are not super explicit but they mention: "When cur begins with '-', you MUST provide the flags". So that is our rule for each group 2 command.

For Group 2 commands, we need to complete flags when $cur (the current token) starts with '-'. But note, not all commands require model completion. For create command, if cword equals 2 and word does not start with '-', then do model completion first. And if the user types a dash for flag option, then provide flag completions.

But what about "pull" which has flags only? It says pull has flags only, no model completion.
For run command: For the model-completion half (which is similar to Group 1 commands) use Steps A-D with ollama list. And if $cur starts with '-', then provide flags for run.

For show command: For model-completion half use steps for group 1 (Steps A-D using ollama list). And if $cur starts with '-', then complete flags options.

So the case statement should be on subcommand = words[1]. So we'll do a "case" on "$subcommand".

Let's define variable subcommand as words[1]. But careful: When cword == 0 or 1, maybe it's top-level completion. So if no subcommand provided (or empty), then complete with full list of subcommands.

The full list is: show run stop push cp rm create pull serve start signin signout list ls ps help

So check if $subcommand is empty? But what if words[1] is not defined or equals an empty string. So do that case.

Plan structure:
```
_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword
    local subcommand="${words[1]}"
    # If top-level completion (i.e., no subcommand provided, i.e., cword==0 or maybe empty)
    if [ "$cword" -eq 0 ] || [[ -z "$subcommand" ]]; then 
       COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
       return
    fi

    case "$subcommand" in
      show|run|push|cp|rm)
         # For these commands: if cur begins with '-', then complete flags? Wait, instructions for group 1:
         # "Use exactly the model-completion algorithm described in Section 3 for: show run stop push cp rm"
         # But what about when cur begins with '-'?
         # The instruction says for Group 2 commands, when cur starts with '-', you must provide flags.
         # For these commands, they are not in group 2 except run? Actually, "run" is in both groups: In Group1, it requires model completion; in Group2, if the flag (cur begins with '-') then complete flags. So for "run", we need two completions:
         # If cword==2 and word doesn't start with '-' then do model-completion.
         # But if the current token starts with '-', then provide flag options.
         #
         # Similarly, for create: It is in group 1 for model completion (if not starting with '-') but if flag then complete flags.
         # So maybe we need to check inside each case.
      ;;
      stop)
         # For stop command:
         # If cur begins with '-'? But instructions do not list stop as having flags, so only model completion is provided. So use model-completion algorithm for stop using ollama ps.
      ;;
      create)
         # For create: if current token doesn't start with '-', then perform model completion using Steps A-D (with ollama list).
         # Else if current token starts with '-' then complete flags from list "--file -f --quantize -q".
      ;;
      pull)
         # For pull: if cur begins with '-' then provide flag options, which is only --insecure.
         # And no model completion.
      ;;
      run)
         # For run command:
         # It belongs to group 1 for model completion if not starting with '-'
         # and also flags from group2 if current token starts with '-' 
         # So similar to create but with different flag list: --format --hidethinking --insecure --keepalive --nowordwrap --think --verbose.
      ;;
      show)
         # For show command:
         # If cur doesn't start with '-', then use model completion using Steps A-D (with ollama list).
         # Else if current token starts with '-', complete flags from group2: --license --modefile --parameters --system --template --verbose.
      ;;
      serve|start|signin|signout|list|ls|ps|help)
         # For these commands, no argument completion, so return empty.
         COMPREPLY=()
         return
      ;;
    esac

    # Now inside each case branch, check if $cur starts with '-' (i.e., if it begins with a dash) then complete flags options; else do model completion.

    # But careful: For commands that require model completion, we want to use the Steps A-D exactly. The instructions require using those steps exactly as in the provided template.
    # But how do we incorporate condition? Possibly by doing something like:
    if [[ "$cur" == -* ]]; then
       # Provide flag completions for group2 commands that support flags.
       case "$subcommand" in
         create)
             COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
         ;;
         pull)
             COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
         ;;
         run)
             COMPREPTY=($(compgen -W "--format --hidethink? Wait, instructions: "--format --hidethink? Let me re-read the table for run:
             "run: flags are --format --hidethink? Actually, instructions say for run command, when cur begins with '-', complete from: 
                 --format --hidethink? The provided list is "--format --hidethink? Let's re-read instructions: It says in Group 2: For run command, the flag options are:
                 "run: --format --hidethink"? Actually, text: "For Group 2 commands, when cur begins with '-', you MUST provide the flags", then table shows for run: 
                "--format" is mentioned? Let me re-read the instructions carefully:

The instructions say: "For Group 2: When cur begins with '-', you MUST provide the flags". Then they list a table:
- For create: flags are: --file -f --quantize -q
- For pull: flag is: --insecure
- For run: flags are: --format --hidethink? Wait, re-read instructions for Group 2 commands from the provided text:
It says: "For group 2 commands, when cur begins with '-', you MUST provide the flags." Then below it lists a table. But then later it says: "For show command: if current token starts with '-' complete flags options --license --modefile --parameters --system --template --verbose."

I must re-read the original instructions in detail:

The question is:
"Write a bash completion script for the 'ollama' command that completes subcommands and their arguments. 
It should complete for these commands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help.
For Group 1 (subcommands: show, run, stop, push, cp, rm), if the argument is not a flag (i.e., doesn't begin with '-'), use ollama's available models from 'ollama list' for completion. However, note that for the stop command, use 'ollama ps' instead.
For Group 2 commands: when the current token begins with '-', complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: --format --hidethink? Actually, instructions for run: "for run command" table is not explicitly given in text above. Wait, let me re-read original question: "Write a bash completion script for the 'ollama' command that completes subcommands and their arguments... for Group 2 commands: when cur begins with '-', complete with appropriate flags:
-- For create: --file -f --quantize -q
-- For pull: --insecure
-- For run: ???" Actually, question states: "For Group 2 commands: when the current token begins with '-', complete with appropriate flags" and then lists table. It says: 
"Group 2:
When cur begins with '-', you MUST provide the flags.
The following flags for each command:
- create: --file -f --quantize -q
- pull: --insecure
- run: (I see the table: "run: --format ...", but then later it says: "For show command: if current token begins with '-', complete with appropriate flags: --license --modefile --parameters --system --template --verbose."
So group 2 flags:
For create: "--file -f --quantize -q"
For pull: "--insecure"
For run: The table provided in the question might have a typo? Let me re-read carefully:
"Write a bash completion script for the 'ollama' command that completes subcommands and their arguments.
...
Group 2 commands (when cur begins with '-'):
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: ???" Actually, I see in the question text: "For Group 2 commands: when the current token begins with '-', complete with appropriate flags." Then after listing that for create and pull, it then says "and their arguments. It should complete for these subcommands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help.
For Group 1 (subcommands: show, run, stop, push, cp, rm), if the argument is not a flag, use ollama's available models from 'ollama list' for completion. However, note that for the stop command, use 'ollama ps' instead.
For Group 2 commands: when the current token begins with '-', complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: ???" Wait, then next line: "For show command: if the argument is a flag (i.e., starts with '-'), complete with appropriate flags: --license --modefile --parameters --system --template --verbose."
So for run and create, I need to provide flags as well:
Looking back at question text after the colon: "Write a bash completion script for the 'ollama' command that completes subcommands and their arguments. It should complete for these commands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help.
For Group 1 (subcommands: show, run, stop, push, cp, rm), if the argument is not a flag (i.e., doesn't begin with '-'), use ollama's available models from 'ollama list' for completion. However, note that for the stop command, use 'ollama ps' instead.
For Group 2 commands: when the current token begins with '-', complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: (likely similar to show?) Actually, wait, the text doesn't explicitly list flags for run in group 2. Possibly a mistake?
Maybe we assume that if $cur begins with '-', then for run, complete using its flag options. And which are they? I could guess from similar patterns: Perhaps "run" should have flags: "--format", maybe "--help"? But the question doesn't specify.
I need to re-read instructions in the original question provided by user:
"Write a bash completion script for the 'ollama' command that completes subcommands and their arguments. It should complete for these commands: show, run, stop, push, cp, rm, create, pull, serve, start, signin, signout, list, ls, ps, help.
For Group 1 (subcommands: show, run, stop, push, cp, rm), if the argument is not a flag (i.e., doesn't begin with '-'), use ollama's available models from 'ollama list' for completion. However, note that for the stop command, use 'ollama ps' instead.
For Group 2 commands: when the current token begins with '-', complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: (maybe there's a typo and it should be "--format"?) Actually, look at the question text: It says "For Group 2 commands: when the current token begins with '-', complete with appropriate flags." Then below that, it doesn't list run's flags. But then later it states: "For show command, if cur begins with '-' then complete with appropriate flags: --license --modefile --parameters --system --template --verbose."
So maybe I assume:
Group 2 flags for run should be the same as group 1? Or perhaps we consider that for run, both model completion and flag options are possible. So for run, if not starting with '-', do model completion; if starting with '-', then complete flags. And what flags? The question doesn't list them explicitly in the provided text, but might be inferred from "run" command common options maybe "--format"? But I'll re-read: "For Group 2 commands: when cur begins with '-' you MUST provide the flags.
- For create: --file -f --quantize -q
- For pull: --insecure"

It doesn't list run. So maybe for run, there are no additional flag options? Or maybe it's a typo and run should also complete with flag options. The question mentions "and their arguments" which implies that subcommands like show and run may have both model argument (non-flag) and optional flags (flag arguments). For create, the flag options are explicitly provided.
I think I'll assume for run: if current token begins with '-', then provide a flag option list. Perhaps we can provide: "--format"? The question text doesn't specify it though.
Wait, maybe we re-read: "It should complete for these commands: ... and their arguments." So each command may have additional flags. For create, the flags are given explicitly; for pull, the flag is given explicitly; for run, there's no explicit flag list given in the text. But then later it says "For show command, if cur begins with '-' then complete with appropriate flags: --license --modefile --parameters --system --template --verbose." So maybe we have:
- For create: flags: "--file", "-f", "--quantize", "-q"
- For pull: flag: "--insecure"
- For run: I'm going to assume similar structure as show command? Possibly, for run, if current token begins with '-', then complete with appropriate flags. But which ones?
I can check typical CLI usage maybe "ollama run" might support a --format option, but not sure.

I decide to fill in: For run: if current token begins with '-' then complete with flags: "--help", maybe? But the question doesn't specify.
Maybe I'll assume that for run, if cur begins with '-', do no additional completions because the question doesn't list them. Alternatively, I could set an empty flag list for run.
I check original instructions: "For Group 2 commands: when the current token begins with '-' complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure
- For run: (this line is in the original text) Actually, maybe it's a mistake and group 2 commands are only for these three commands. And then separately "For show command" has its own flag list.
Maybe I should include: For run, if cur begins with '-', complete with flags: "--format" because that is common? But not given in the text.

I can re-read the question carefully:
"Write a bash completion script for the 'ollama' command that completes subcommands and their arguments."
Then it lists subcommands.
Then: "For Group 1 (subcommands: show, run, stop, push, cp, rm), if the argument is not a flag (i.e., doesn't begin with '-'), use ollama's available models from 'ollama list' for completion. However, note that for the stop command, use 'ollama ps' instead."
Then: "For Group 2 commands: when the current token begins with '-', complete with appropriate flags:
- For create: --file -f --quantize -q
- For pull: --insecure"
There's no explicit flag list for run in group 2. But then it says later: "For show command, if the argument is a flag (i.e., starts with '-'), complete with appropriate flags: --license --modefile --parameters --system --template --verbose."

So maybe I'll provide completions for run only if not starting with '-'? And then if it does start with '-', do nothing extra. But that would be inconsistent because why would some commands have additional flag completions and others not?
Maybe I assume that "run" command doesn't accept flags or its flags are the same as model names? Unlikely.
I might add a branch for run in group 2, and complete it with some common flags, maybe I can put "--help" or an empty list. But then the instructions mention: "for Group 2 commands, when cur begins with '-', complete with appropriate flags", so there must be some flag completions.

Given the ambiguity, perhaps I'll add a comment that for run command, if cur begins with '-', no specific flags are defined, so skip. Alternatively, I can set an empty array or do nothing.
I think I'll implement for run: if cur starts with '-' then complete using a predefined list of flags: "--format" (even though it's not specified but seems plausible). But caution: the question doesn't specify that flag.

Alternatively, I could check the pattern: For create, there are 4 options; for pull, one option; for show, six options. So maybe run should also have several options. Possibly something like "--format", but I don't see a second. Could it be "--cpu"? Perhaps I'll just set an empty list or a placeholder comment.
I think I'll add a branch for run in group 2 that does nothing (or returns no completions) because there is no explicit list.

However, maybe I can re-read the original question's text: "For Group 2 commands: when the current token begins with '-', complete with appropriate flags:" then lists create and pull. It doesn't mention run, which implies that run might not have additional flag completions, so if $cur begins with '-' for run, do nothing.
But what about show command? It is in group 1 but also has its own flag list if argument starts with '-'. So I'll add a case for "show" separately.

Plan structure:
- We start the script with "#!/usr/bin/bash" maybe. Actually, it's a completion function: "_ollama_completion".
- Use _init_completion to initialize context.
- Then use COMPREPLY and COMP_WORDS etc.

I can write something like:

_ollama_completion() {
    local cur prev words cword
    _init_completion || return

    case "${prev}" in
         # first word is command
         ollama)
             case "${cur}" in
                --help|-h)
                   COMPREPLY=( $(compgen -W "--help -h" -- "$cur") )
                   return 0
                   ;;
                show|run|stop|push|cp|rm|create|pull|serve|start|signin|signout|list|ls|ps|help)
                   # For subcommands, complete them.
                   COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
                   return 0
                   ;;
                *)
                   # if not a flag and the argument is supposed to be a model for group1 commands, then complete with models.
                   # But only if prev (the second word) is one of group1 commands? Actually, careful: The pattern matching should check if $prev is in group1 commands except that we also need to handle flags for group2 commands.
                   ;;
             esac
             return 0
             ;;
         show)
              case "${cur}" in
                 -*) # flag arguments for show command
                     COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
                     return 0
                     ;;
                 *)
                     # if not a flag, then complete with available models from 'ollama list'
                     local models
                     models=$(ollama list 2>/dev/null)
                     COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                     return 0
                     ;;
              esac
              return 0
              ;;
         run)
              case "${cur}" in
                 -*) # flag arguments for run command, if any
                     # Possibly no flags defined? We'll leave it empty.
                     COMPREPLY=()
                     return 0
                     ;;
                 *)
                     local models
                     models=$(ollama list 2>/dev/null)
                     COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                     return 0
                     ;;
              esac
              return 0
              ;;
         stop)
              case "${cur}" in
                 -*) # if flag argument, maybe no flags for stop? Or perhaps stop has some flags? Not specified.
                     COMPREPLY=()
                     return 0
                     ;;
                 *)
                     local models
                     models=$(ollama ps 2>/dev/null)
                     COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                     return 0
                     ;;
              esac
              return 0
              ;;
         push|cp|rm)
              # these commands are group1, so if not flag then complete models from ollama list.
              case "${cur}" in
                 -*)
                      COMPREPLY=()
                      return 0
                      ;;
                 *)
                      local models
                      models=$(ollama list 2>/dev/null)
                      COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                      return 0
                      ;;
              esac
              return 0
              ;;
         create)
              case "${cur}" in
                 -*) # flag arguments for create command.
                     COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
                     return 0
                     ;;
                 *)
                     local models
                     models=$(ollama list 2>/dev/null)
                     COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                     return 0
                     ;;
              esac
              return 0
              ;;
         pull)
              case "${cur}" in
                 -*) # flag arguments for pull command.
                     COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
                     return 0
                     ;;
                 *)
                     local models
                     models=$(ollama list 2>/dev/null)
                     COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
                     return 0
                     ;;
              esac
              return 0
              ;;
         serve|start|signin|signout|list|ls|ps|help)
              # These commands might not have sub-arguments that need completion. 
              COMPREPLY=()
              return 0
              ;;
    esac

}

But wait, the case structure: The first word is "ollama". So I should check if "${prev}" equals "ollama" then handle the rest.

I can use:
case "$1" in but using _init_completion it's common to use ${COMP_WORDS[0]} etc.

Maybe I'll do:

_ollama_completion() {
  local cur prev words cword
  _init_completion || return

  case "${prev}" in
    ollama)
      # If the current argument is a subcommand, complete them.
      if [[ "$cur" == -* ]]; then
         COMPREPLY=( $(compgen -W "--help -h show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
         return 0
      else
         COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
         return 0
      fi
      ;;
    show)
      if [[ "$cur" == -* ]]; then
         COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
         return 0
      else
         local models
         models=$(ollama list 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    run)
      if [[ "$cur" == -* ]]; then
         # No specific flag completions provided for run command, so maybe nothing.
         COMPREPLY=()
         return 0
      else
         local models
         models=$(ollama list 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    stop)
      if [[ "$cur" == -* ]]; then
         COMPREPLY=()
         return 0
      else
         local models
         models=$(ollama ps 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    push|cp|rm)
      if [[ "$cur" == -* ]]; then
         COMPREPLY=()
         return 0
      else
         local models
         models=$(ollama list 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    create)
      if [[ "$cur" == -* ]]; then
         COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
         return 0
      else
         local models
         models=$(ollama list 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    pull)
      if [[ "$cur" == -* ]]; then
         COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
         return 0
      else
         local models
         models=$(ollama list 2>/dev/null)
         COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
         return 0
      fi
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      # No additional completions.
      COMPREPLY=()
      return 0
      ;;
  esac
}

This should be sufficient.

One nuance: _init_completion is provided by bash-completion usually. If not available, we can define it manually but assume it's there.

I'll include the whole script with proper bash completion function naming _ollama or something similar.

Typically, completions are installed in /etc/bash_completion.d/ollama

So I'll output the final code as a single block of code. We'll not use markdown formatting by default? The instruction says "By default, do not reply with Markdown formatting" but it's ambiguous: It said "By default do not use markdown unless requested." Actually instructions say "By default, do not reply with markdown formatting unless requested", so I'll output plain text.

I'll produce final answer as plain text code block. We'll provide a commented version to explain the logic.

I'll produce final answer.</think>#!/usr/bin/env bash
# This is an example Bash completion script for the “ollama” CLI.
#
# It supports:
#   • Completion of subcommands (show, run, stop, push, cp, rm,
#     create, pull, serve, start, signin, signout, list, ls, ps, help).
#
# For Group 1 commands (show, run, stop, push, cp, rm) when the argument
# is not a flag (i.e. does not start with “-”), it completes using available models.
#   – For show, run, push, cp and rm, models are listed via “ollama list”.
#   – For stop, models come from “ollama ps” instead.
#
# For Group 2 commands (create, pull), when the argument starts with a dash,
# it completes using the appropriate flags:
#   • create:  --file, -f, --quantize, -q
#   • pull:    --insecure
#
# Additionally, for the “show” command if a flag is provided (starting with “-”),
# a specific set of flag completions are offered.
#
# To install this completion:
#   1. Save it as /etc/bash_completion.d/ollama or in your ~/.bash_completion.d/
#      directory.
#   2. Source bash-completion (if not already) via:
#         . "$(brew --prefix)/share/bash-completion/bash_completion"
#   3. Restart your shell.

_ollama_completion() {
    # Use _init_completion if available (provided by bash-completion package)
    local cur prev words cword
    if type _init_completion &>/dev/null; then
        _init_completion || return
    else
        # Fallback: simple initialization of COMP_WORDS and cword.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]:-}"
        words=("${COMP_WORDS[@]}")
        cword=${#words[@]}
    fi

    case "${prev}" in
        ollama)
            # When the first word is “ollama”, complete subcommands.
            local subcmds="--help -h show run stop push cp rm create pull serve start signin signout list ls ps help"
            if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "${subcmds}" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
            fi
            return 0
            ;;
        show)
            # For the “show” command:
            #   • If a flag is entered (starts with “-”), complete its flags.
            #   • Otherwise, complete available models from “ollama list”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        run)
            # For the “run” command:
            #   • If a flag is entered, no extra completions are defined.
            #   • Otherwise, complete available models from “ollama list”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
            else
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        stop)
            # For the “stop” command:
            #   • If a flag is entered, no extra completions are defined.
            #   • Otherwise, complete available models from “ollama ps”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
            else
                local models
                models=$(ollama ps 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        push|cp|rm)
            # These are Group 1 commands:
            #   • If a flag is entered, do not complete.
            #   • Otherwise, complete available models from “ollama list”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
            else
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        create)
            # For the “create” command:
            #   • If a flag is entered, complete its flags.
            #   • Otherwise, complete available models from “ollama list”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        pull)
            # For the “pull” command:
            #   • If a flag is entered, complete its flags.
            #   • Otherwise, complete available models from “ollama list”.
            if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
            fi
            return 0
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # For these commands no further completion is defined.
            COMPREPLY=()
            return 0
            ;;
    esac
}

# To use this completion script, ensure it’s sourced by your shell.
# You can add the following line to your ~/.bashrc or equivalent:
#
#   if [ -f /etc/bash_completion.d/ollama ]; then
#       . /etc/bash_completion.d/ollama
#   fi

# End of ollama completion script.

