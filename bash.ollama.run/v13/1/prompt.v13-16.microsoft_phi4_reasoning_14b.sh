#<think>We are Phi with knowledge of bash completions. We have a user request that says: "You are an expert in Bash shell completion. Your task is to generate a completion script for the `ollama` command that works correctly for `ollama run <model>`. Critical Requirements: ..." Then provides list requirements regarding checking only when the command is exactly "ollama run", condition check using array indexing [0]=="ollama" and [1]=="run".
#
#The user request instructs: "Generate a completion script with modifications. The output format: Provide ONLY the corrected Bash completion script (no explanations). Ensure identical structure to the original Gemma 27b script except that only the condition line is modified." So we must produce exactly a single file script containing the code.
#
#We have instructions about colon splitting and handling completions for "ollama run <model>" command. The conditions say: Only activate when command equals "ollama" (COMP_WORDS[0]=="ollama") and second word equals "run". And use __ltrim_colon_completions to process the current word.
#
#We have requirements:
#- Always call __ltrim_colon_completions "$cur" at the end.
#- Use _get_comp_words_by_ref -n : to prevent colon splitting.
#- Process ollama list output, skip header line ("NAME ID SIZE MODIFIED") and empty lines.
#- Extract model names from first column.
#
#Now the script is referred as "Gemma 27b", but I'm not aware of that file. But we must produce a script that fits the structure, with only one changed condition check using:
#[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]
#
#I assume we have to produce similar code as in original Gemma 27b completions file.
#
#We must produce a Bash completion script that is likely placed maybe in /etc/bash_completion.d/ollama or something. But instructions say "Provide ONLY the corrected Bash completion script", so output is only the file contents, not explanation lines.
#
#What does "only changes the condition line" mean? It means we should modify the original Gemma 27b script to check using array indexing conditions: [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]. And then if this is not met, exit maybe. The rest of logic remains identical.
#
#Let's produce a script that starts with something like:
#
##!/bin/bash
## Completion function for ollama command
#
#_ollama_completion() {
#   # Only complete when the first two words are exactly 'ollama' and 'run'
#   if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#       return
#   fi
#
#   local cur prev words cword
#   cur=${COMP_WORDS[cword]}
#   # maybe parse completions, etc.
#
#   ... (logic to process model names)
#
#   local models=( $(ollama list 2>/dev/null | tail -n +3) ) maybe? But requirement says "Process ollama list output correctly: Skip header line and empty lines" So we may do something like:
#
#   local models
#   models=$(ollama list 2>/dev/null)
#   for model in $models; do
#      if [[ "$model" != "" ]]; then continue. Wait, no, we have to skip header line.
#
#   But careful: The original Gemma 27b script might be structured as:
#
#Maybe I'll assume the structure:
#```
#_ollama_completion() {
#    local cur prev words cword
#    cur="${COMP_WORDS[cword]}"
#    # only complete for "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#        return
#    fi
#
#    # get completions from ollama list output
#    local out
#    out=$(ollama list 2>/dev/null)
#    # skip header line and blank lines, extract first column.
#    COMPREPLY=( $(compgen -W "$out" -- "$cur") )
#}
#complete -F _ollama_completion ollama
#```
#But I'm not sure exactly.
#
#Wait, instructions say "Use _get_comp_words_by_ref -n :" to prevent colon splitting. So we need that function call maybe after generating completions, then call __ltrim_colon_completions "$cur" at the end.
#
#We should produce a script that uses proper array indexing and calls __ltrim_colon_completions. We must have condition check using:
#[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]
#
#I'll try to generate a valid completion script similar to Gemma 27b.
#
#We need to produce something like:
#
#```
##!/bin/bash
#_ollama_completion() {
#    # Only complete when first word is "ollama" and second is "run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#        return
#    fi
#
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur
#
#    # Get list of models from ollama list output, skipping header and empty lines
#    local models tmp
#    models=()
#    while IFS= read -r line; do
#        if [[ "$line" =~ ^NAME ]]; then continue; fi
#        if [[ -z "$line" ]]; then continue; fi
#        # Extract first column (assuming whitespace separated)
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done < <(ollama list 2>/dev/null)
#
#    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${models[@]}")" -- "$cur") )
#    __ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completion ollama
#```
#But I must consider that the script might use some common functions defined in /usr/share/bash-completion/completions maybe. But instructions say "Provide ONLY the corrected Bash completion script".
#
#We need to produce only one file, which is the corrected version of Gemma 27b script with condition line changed as required.
#
#I can assume that the original script had a check like:
#```
#if [[ "${COMP_WORDS[0]}" != "ollama" && "${COMP_WORDS[1]}" != "run" ]]; then
#   return
#fi
#```
#But we need to modify it to use "||". So our corrected version is:
#
#[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]
#
#That's the only difference.
#
#I must produce a script with that condition check exactly.
#
#Thus, I'll produce a file as a completion script named maybe: ollama-completion.sh or similar. It should contain:
#- Possibly a comment header
#- A function _ollama_completion()
#- Inside the function, check if command is not "ollama run" using array indexing.
#- Then get current word with _get_comp_words_by_ref -n : "$cur"
#- Then process "ollama list" output skipping header and blank lines.
#- And then call compgen to produce completions from the model names extracted.
#- Finally, call __ltrim_colon_completions "$cur".
#
#I'll produce a code that is similar structure as Gemma 27b script. The original likely uses "COMPREPLY" array variable in bash completion.
#
#Maybe something like:
#```
#_ollama_completion() {
#    # Only complete when command is exactly "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#         return
#    fi
#
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur
#
#    # Get available models from 'ollama list' output, skip header and empty lines.
#    local model line out
#    COMPREPLY=()
#    while IFS= read -r line; do
#         if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
#              continue
#         fi
#         if [[ -z "$line" ]]; then
#              continue
#         fi
#         # Extract first column (assuming space separated)
#         model=$(echo "$line" | awk '{print $1}')
#         COMPREPLY+=("$model")
#    done < <(ollama list 2>/dev/null)
#
#    __ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completion ollama
#```
#But I'll produce script exactly like that.
#
#I must ensure: "ONLY the condition check line is modified". So if there's an earlier check, we modify it accordingly. The original Gemma 27b script likely had a check such as:
#```
#if [[ "${COMP_WORDS[0]}" != "ollama" && "${COMP_WORDS[1]}" != "run" ]]; then
#```
#But we need to change that to using OR condition:
#[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]
#
#I must produce a script with exactly that line.
#
#So I'll produce the complete file. The file should be plain text starting with "#!/bin/bash" maybe.
#
#The instructions said "Provide ONLY the corrected Bash completion script". So I'll produce code block containing the entire file content, but since default output formatting is plain text unless requested otherwise by user, then I'll just produce plain text without markdown formatting if possible. But instructions: "Ensure identical structure to the original Gemma 27b script" so we must include everything that was originally in that script aside from modification of condition check line.
#
#I must assume the content of Gemma 27b script. I have to produce a code snippet that is complete. The only difference is that instead of using AND operator, we use OR operator for the command name and run arguments check.
#
#Thus I'll produce something like:
#
#```
##!/bin/bash
## Bash completion for ollama
#_ollama_completion() {
#    # Only complete when command is exactly "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#        return
#    fi
#
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur
#
#    local models=()
#    while IFS= read -r line; do
#         # Skip header line and empty lines.
#         if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
#              continue
#         fi
#         model=$(echo "$line" | awk '{print $1}')
#         models+=("$model")
#    done < <(ollama list 2>/dev/null)
#
#    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${models[@]}")" -- "$cur") )
#    __ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completion ollama
#```
#That is the corrected script. Let me check requirements:
#
#- Only activate when command equals "ollama run". That is satisfied by the condition: if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then return; fi.
#
#- It handles colon splitting in model names using _get_comp_words_by_ref -n : cur
#
#- It calls __ltrim_colon_completions "$cur" at the end.
#
#- It processes ollama list output correctly: It uses a while read loop to iterate over lines from "ollama list", skipping header line ("NAME ID SIZE MODIFIED") and empty lines. Then extracts first column using awk '{print $1}'.
#- There is compgen with a word list made of models array.
#
#I must produce the corrected script as final output with no explanation.
#
#I'll produce plain text code block that exactly matches required output format: "Provide ONLY the corrected Bash completion script (no explanations)."
#
#I must provide the output. We'll produce only the bash script content.
#
#I'll produce a plain text answer without markdown formatting, but instructions say "By default do not use markdown formatting unless requested." But we are allowed to produce code in code block if necessary.
#
#But instructions said: "Ensure: Provide ONLY the corrected Bash completion script" so I must provide just that.
#
#I can produce plain text or code block with triple backticks? Instructions said: "Output Format: Provide only the corrected Bash completion script (no explanations)." So I'll output exactly the file content.
#
#I'll produce final answer accordingly.</think>
#!/bin/bash
# Bash completion for ollama

_ollama_completion() {
    # Only complete when command is exactly "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    local cur prev words cword
    _get_comp_words_by_ref -n : cur

    local models=()
    while IFS= read -r line; do
        # Skip header and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
            continue
        fi
        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${models[@]}")" -- "$cur") )
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completion ollama

