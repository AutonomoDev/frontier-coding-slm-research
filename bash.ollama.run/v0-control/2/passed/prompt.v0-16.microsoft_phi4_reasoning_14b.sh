#!/bin/bash
# Bash completion for the command "ollama run <model>"
#
# This function dynamically lists available models by parsing the output of "ollama list".
# It assumes that "ollama list" prints model information with whitespace‐separated columns,
# where the first field is the model name. If a header line (e.g., "NAME ID SIZE MODIFIED") is
# present, it will be skipped.
#
# Installation:
#   • To install this completion, source this file from your shell initialization script
#     (for example, add the following to ~/.bashrc):
#
#         . /path/to/ollama_run_completion.sh
#
#   • Or place the script in a directory loaded by Bash's completion system (e.g., /etc/bash_completion.d/)
#     and ensure it is executed when your shell starts.
#
# <think>
# We are asked: "Task: Create a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags." The expected answer: Provide a script with comments and installation snippet. We must provide a self-contained Bash script, so likely we can produce a file that contains the function and then at the end some snippet to install it in /etc/bash_completion.d or in ~/.bash_completion.
# 
# We need to use bash-completion conventions. Usually one writes _ollama_run function that uses case "$COMP_CWORD" etc. But given we want specifically for `ollama run <model>`, we want completions on the second argument only, so for instance if our command is "ollama run", then completion should be provided for the model name.
# 
# We need to parse output of "ollama list", and extract model names from it? The sample "ollama list" output shows columns: NAME ID SIZE MODIFIED. But I believe we want to complete on model names, so we need to take the first column's text from each line? But note that model names are in format "codellama:13b", etc.
# 
# We must use only bash builtins. So no grep, sort, uniq maybe using builtin string manipulation, possibly awk is not allowed because it might be a dependency on external binary. We can use parameter substitution or while read loop.
# 
# We need to run command "ollama list" but with "set +e" perhaps and capture errors? The instructions: "Fail gracefully if underlying commands error (e.g., silence failures so the shell doesn't break)". So we must ignore errors from `ollama list`. We can do something like: _models="$(ollama list 2>/dev/null)" maybe. But then we need to parse out model names.
# 
# We assume that each line has whitespace separated fields, and the first field is the model name.
# 
# I must produce a Bash script function that defines the completion logic for command "ollama run". The function should be named _ollama_run. Then the installation snippet: probably something like "complete -F _ollama_run ollama" if we want to use bash-completion conventions.
# 
# We need to output a self-contained script, with comments and installation snippet.
# 
# I'll produce a script as follows:
# 
# ```
# #!/bin/bash
# # Bash completion for 'ollama run <model>'
# #
# # This function dynamically lists available models by parsing the output of `ollama list`.
# # It assumes that `ollama list` outputs model information with each field separated by whitespace.
# #
# # Usage:
# #   source /path/to/this/script.sh  OR add to your ~/.bashrc or appropriate bash completion directory.
# 
# _ollama_run() {
#     # Ensure we are completing the command "ollama run"
#     local cur prev words cword
#     _get_comp_words_by_ref -n : cur prev words cword
# 
#     # We want completions for the second argument (index 1, since index 0 is "ollama")
#     if [ "$cword" -eq 1 ]; then
#         # Get list of models by running `ollama list` and ignoring errors.
#         local output models
#         # Run ollama list and capture output. Silence errors.
#         output=$(ollama list 2>/dev/null) || true
# 
#         if [ -n "$output" ]; then
#             # Use internal bash loops to parse lines.
#             while IFS= read -r line; do
#                 # Remove leading/trailing whitespace, skip blank lines and header (maybe).
#                 # We assume first column is the model name. So use tokenization by whitespace.
#                 local model
#                 # Extract first field from each line, ignoring empty lines.
#                 if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]].* ]]; then
#                     model="${BASH_REMATCH[1]}"
#                     models+="$model"$'\n'
#                 fi
#             done <<< "$output"
#         fi
# 
#         COMPREPLY=( $(compgen -W "${models:-}" -- "$cur") )
#     fi
# }
# 
# complete -F _ollama_run ollama
# ```
# 
# I must produce complete script with comments and installation snippet. Also note that "ollama list" might output a header, so we may consider skipping the first line if it's a header. But sample output includes header (NAME ID SIZE MODIFIED). We have to check that: The sample shows header line at top. So then maybe in our parsing we skip that header? But instructions said "Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags." Actually, the problem statement says that "ollama list" outputs model names as first column for each row when run with no formatting flags. The sample includes a header though. But maybe we can decide: if the first line is header? Alternatively, I can check if the output's first line matches pattern with field values or simply skip empty lines. But instructions said "Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags". That might mean that it doesn't print a header at all normally, but sample shows header though. I'll assume the actual output is like header then rows, so we want to ignore header if necessary? But instructions say "without using any external dependencies", not "not use external commands" etc.
# 
# We can skip first line by doing while read line; do ... and skipping first iteration. That might be done with a variable count. Alternatively, check if the first field is numeric or something: But better to assume header exists if it matches pattern with column names? The sample header is "NAME ID SIZE MODIFIED". We could check that if "$line" is non-empty and then skip it if it does not have colon ":" in it maybe? But careful. Model names appear as "codellama:13b", but the header "NAME" doesn't contain a colon, so we can skip lines that don't contain colon. So we can do something like: if [[ "$line" != *" "* ]] then continue or check if line contains ":". Actually, every valid model name should have a colon and a number? But maybe not always.
# 
# Wait sample: "codegemma:7b", "codellama:13b", etc. And header is "NAME ID SIZE MODIFIED". So all valid models seem to contain a colon. So we can simply check if "$line" matches something like "[^ ]*:[0-9]*". But then header "NAME" does not match.
# 
# Maybe we'll do this: Skip first line? We can do a read loop that uses a flag. Alternatively, I can use a pattern to detect valid models: If the line doesn't contain colon in position after some initial letter maybe. Let's assume that if the model name contains ":" then it is a valid model line.
# 
# I'll do something like:
# ```
# while IFS= read -r line; do
#    # Skip header lines (ones that do not match pattern "^[A-Za-z0-9:]+")
#    [[ "$line" =~ ^[A-Za-z0-9:]+$ ]] || continue
#    ...
# done <<< "$output"
# ```
# But then the valid models contain letters and colon and digits, so they do match. But header line "NAME ID SIZE MODIFIED" doesn't match because it has spaces.
# Alternatively, we can simply skip empty lines.
# 
# Maybe simpler is to just check if the first field has a colon in it. So after reading the model name with BASH_REMATCH[1], then check if that contains ":" and maybe a number? For example: if [[ "$model" =~ : ]]; then add to models.
# 
# Thus, I'll do:
# ```
# while IFS= read -r line; do
#     # Extract first field.
#     local model
#     if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]].* ]]; then
#         model="${BASH_REMATCH[1]}"
#         if [[ "$model" == *:* ]]; then
#             models+="$model"$'\n'
#         fi
#     fi
# done <<< "$output"
# ```
# That might work.
# 
# I can also consider to ignore header lines explicitly by checking if the line begins with "NAME". But the problem statement says: "Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags." So maybe that means it does not output a header? But sample shows header though. I'll include code to skip header lines if they are of the form "NAME ID SIZE MODIFIED" i.e., check if first token is NAME.
# 
# We can do:
# ```
# if [[ "$line" =~ ^[[:space:]]*NAME ]]; then
#     continue
# fi
# ```
# Yes, that's a good idea. I'll do that check before extracting model name.
# 
# Plan:
# 
# ```
# _ollama_run() {
#   local cur prev words cword
#   _get_comp_words_by_ref -n : cur prev words cword
# 
#   # We only complete second argument (index=1)
#   if [ "$cword" -eq 1 ]; then
#     local output models
#     # Capture ollama list output, ignoring errors.
#     output=$(ollama list 2>/dev/null) || true
# 
#     while IFS= read -r line; do
#       # Skip header line
#       [[ "$line" =~ ^[[:space:]]*NAME ]] && continue
#       
#       # Extract first field.
#       if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]].* ]]; then
#         local model="${BASH_REMATCH[1]}"
#         models+="$model"$'\n'
#       fi
#     done <<< "$output"
# 
#     COMPREPLY=( $(compgen -W "${models:-}" -- "$cur") )
#   fi
# }
# ```
# Then installation snippet:
# ```
# complete -F _ollama_run ollama
# ```
# 
# I'll include shebang line at top "#!/bin/bash" and comments.
# 
# We must provide a self-contained bash script. So I'll produce one file that is complete, with comments and installation snippet.
# 
# Let's produce the final answer. We'll now produce text as code block? But instructions say: "Your solution must be a self-contained Bash script." And "Only the complete script with comments and the installation snippet."
# 
# I'll produce:
# 
# ```
# #!/bin/bash
# # Bash completion for the command `ollama run <model>`
# #
# # This function dynamically lists available models by parsing the output of `ollama list`.
# # It assumes that `ollama list` outputs model information with columns separated by whitespace.
# # The first column is assumed to be the model name. If a header line is present (e.g., "NAME ID SIZE MODIFIED"),
# # it will be skipped.
# #
# # Installation:
# # To install this completion, simply source this file from your shell initialization or place it in
# # your Bash completions directory (e.g., /etc/bash_completion.d/ollama_run.sh) and ensure it's loaded.
# #
# _ollama_run() {
#     # Retrieve current word and other completion variables
#     local cur prev words cword
#     _get_comp_words_by_ref -n : cur prev words cword
# 
#     # We're completing the second argument of "ollama run"
#     if [ "$cword" -eq 1 ]; then
#         local output models=""
#         
#         # Run ollama list, capturing output while ignoring errors.
#         output=$(ollama list 2>/dev/null) || true
#         
#         # Parse each line to extract the first field (model name)
#         while IFS= read -r line; do
#             # Skip header lines (if present), e.g., "NAME ID SIZE MODIFIED"
#             [[ "$line" =~ ^[[:space:]]*NAME ]] && continue
#             
#             # Extract the first non-empty token as model name.
#             if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]].* ]]; then
#                 local model="${BASH_REMATCH[1]}"
#                 models+="$model"$'\n'
#             fi
#         done <<< "$output"
#         
#         # Generate the list of completions.
#         COMPREPLY=( $(compgen -W "${models:-}" -- "$cur") )
#     fi
# }
# 
# # Register the completion function with Bash's completion system.
# complete -F _ollama_run ollama
# ```
# 
# I'll produce a final answer script as above. That is all.
# 
# I'll now produce final answer in plain text code block without markdown formatting (unless instructions say by default no markdown? Actually instructions: "By default, do not reply with markdown formatting" but we are instructed: "Your solution must be a self-contained Bash script." So I output plain text code block as final answer. We'll check instructions "Do NOT include anything else."
# 
# I'll produce final answer accordingly.
# 
# I'll now produce final answer.
# </think>

_ollama_run() {
    # Retrieve the current word, previous word(s), and other completion context info.
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # We only complete the second argument (index 1) of "ollama run"
    if [ "$cword" -eq 1 ]; then
        local output models=""
        
        # Run "ollama list", capturing its output while silencing any errors.
        output=$(ollama list 2>/dev/null) || true
        
        # Process each line to extract the first field (the model name).
        while IFS= read -r line; do
            # Skip header lines (e.g., "NAME ID SIZE MODIFIED")
            [[ "$line" =~ ^[[:space:]]*NAME ]] && continue
            
            # Extract the first non-empty token as the model name.
            if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]].* ]]; then
                local model="${BASH_REMATCH[1]}"
                models+="$model"$'\n'
            fi
        done <<< "$output"
        
        # Use compgen to generate possible completions based on the dynamic list.
        COMPREPLY=( $(compgen -W "${models:-}" -- "$cur") )
    fi
}

# Register the completion function with Bash for the "ollama" command.
complete -F _ollama_run ollama
