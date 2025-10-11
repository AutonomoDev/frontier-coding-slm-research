#<think>
#We are given task: "Create a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies." We have sample output. And we need to produce self-contained script with comments and installation snippet.
##I must produce a bash completion script for command "ollama run" using dynamic listing of model names by reading `ollama list` output, which prints some header lines and then rows of models. The completion function should parse the output, possibly ignoring header lines? But we assume that available models are printed in each row after the header line. It says sample ollama list output:
#```
#NAME ID SIZE MODIFIED
#codegemma:7b 0c96700aaada 5.0 GB 12 days ago
#codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
#codestral:22b 0898a8b286d5 12 GB 12 days ago
#```
#So we can assume that the header is first line and then subsequent lines are models, with a model name in first column? But careful reading: "Assume ollama list prints model names one per line (or separated by whitespace) when run with no formatting flags." So they want to use output of `ollama list` command as a source for available models. We might need to parse the header and then the lines. The sample output has first line that is column headers; then subsequent lines are actual data rows.
#
#The completion function will be executed by bash-completion mechanism, which typically uses _ollama_run function in .bash_completion or similar file. But script should contain instructions how to install it. I'll produce a self-contained script that defines the completion function and then instructs user how to put this into ~/.bashrc or /etc/bash_completion.d.
#
#Plan: The function for ollama run is _ollama_run. We need to check if $COMP_CWORD (word index) equals 2? Because command line is "ollama run <model>" so first argument is always "run" and second token should be model name; we want to provide completions if the current token being completed is at position 1 or perhaps also check for word count. But typical convention: When completing a subcommand of "ollama", then our function is triggered by "ollama run". The completion function may use _arguments to complete both subcommands and models.
#
#However, in this problem we are just given task: "Create bash-completion function for command `ollama run <model>`" which means that the completion script should generate completions from available model names parsed from ollama list output. And note that it must not use external dependencies (no jq or similar) so we have to rely on shell built-ins and maybe sed/awk if needed. But can I use awk? That is core utility. But might be better to use "read" with IFS.
#
#I could do something like:
#
#function _ollama_run_completion() {
#  # parse ollama list output, skipping header line
#  local models=()
#  
#  # capture the output of ollama list command while ignoring errors: Use set +e
#  # We can use "OLLAMA_LIST_OUTPUT=$(ollama list 2>/dev/null)" to avoid error output.
#  
#  OLLAMA_LIST_OUTPUT=$(ollama list 2>/dev/null)
#  if [[ $? -ne 0 || -z "$OLLAMA_LIST_OUTPUT" ]]; then
#    return
#  fi
#  
#  # Now we need to parse the output, ignoring header line. The first non-empty line is header.
#  # I can store lines in an array variable and then loop from second element onward.
#  
#  local IFS=$'\n'
#  read -rd '' -a arr <<< "$OLLAMA_LIST_OUTPUT" || return
#  
#  # skip header: maybe check for non empty lines?
#  # Alternatively, if the output always has a header line with "NAME", we can detect that
#  local header=${arr[0]}
#  
#  # Then loop over rest of array (starting index 1)
#  local models=() # declare new variable
#  for (( i = 1; i < ${#arr[@]}; i++ )); do
#      # We want to complete based on the first column: which might be the model name.
#      # But the sample output is "codegemma:7b" etc. So we can just complete full line?
#      
#      local token=$(echo "${arr[$i]}" | awk '{print $1}')
#      models+=("$token")
#  done
#
#  COMPREPLY=( $(compgen -W "${models[*]}" -- "$COMP_LINE") )
#  return 0
#}
#
#But then the function should be triggered only if we are completing "ollama run" and there is argument to complete. But usually completion function naming conventions: _ollama_run().
#
#I also recall that when writing completions for commands with subcommands, sometimes you use a dispatcher function (like _ollama) which calls specific subcommand functions like _ollama_run, etc.
#
#The instructions say "for the command `ollama run <model>`". So I assume we are to complete after "run", i.e., index 1. So our function should check if $COMP_CWORD equals 2 (or maybe >=2). Because first token is "ollama", second token is "run" but then third is model. But the user said: command "ollama run <model>". The completion function should provide completions for the <model> argument.
#
#I can do something like:
#
#_ollama_run_completion() {#  # Check that we are completing the third word.
#  if [[ $COMP_CWORD -le 2 ]]; then
#      return
#  fi
#
#  # Get models from ollama list output:
#  local models=()
#  local out
#  out=$(ollama list 2>/dev/null || true)  # but must not break shell completion on error; using "|| true" to silence errors.
#
#  if [[ -z "$out" ]]; then
#    return
#  fi
#
#  # The output contains header line and then model lines.
#  local IFS=$'\n'
#  read -rd '' -a lines <<< "$out"
#
#  for (( i=1; i<${#lines[@]}; i++ )); do
#      # The first column is the model name, which might have extra spaces. Use awk to extract first word.
#      # But maybe use "cut" or "awk". I'll use awk: echo "$line" | awk '{print $1}'
#      local model
#      model=$(echo "${lines[$i]}" | awk '{print $1}')
#      models+=("$model")
#  done
#
#  COMPREPLY=( $(compgen -W "${models[*]}" -- "${COMP_WORDS[2]}") )
#}
#
#That is the basic function.
#
#But be careful: The completion function should check number of words. But COMP_CWORD counts starting from 0, so maybe we want to complete when $COMP_CWORD >=3 because:
#- Word index 0: ollama
#- word index 1: run
#- word index 2: <model>
#
#So I'll put if [[ $COMP_CWORD -le 2 ]]; then return; fi.
#
#I need to use "set +e" maybe? But the instructions say: "Fail gracefully if underlying commands error (e.g., silence failures so the shell doesn't break)". So using "|| true" is a possibility. However, using "ollama list || true" might not work because that command is run when completion function is invoked, and if it fails then output is empty string. But instructions say: fail gracefully.
#
#So I'll do:
#    out=$(ollama list 2>/dev/null || true)
#
#I can also use "set +e" to silence errors but then restore error status? Actually, it's better to use || true in the command substitution, so that if ollama list returns non-zero then output remains empty. That is fine.
#
#We then parse out lines using IFS=$'\n' read -rd '' into array variable 'lines'. But careful: "read -rd" option is available in bash 4.2+ but may not be POSIX? It says "typical posix/bash environment", so maybe we can assume Bash with version 3? Not sure. But using "read -d" is a Bash extension if no read -r doesn't allow newlines? Alternatively, use something like:
#  lines=($out)
#But that might break on spaces if output has whitespace. The sample output: each line is separate. There are no extra whitespace issues because each line is separated by newline. So we can do:
#  
#   readarray -t lines <<< "$out"
#  
#This is available in bash as "readarray" and it's recommended for reading arrays from a variable, but that might not be POSIX? But instructions say: "typical POSIX/bash environment", so I think it's safe to assume bash.
#
#I can do:
#  readarray -t lines < <(ollama list)
#But then need to skip header line. So either use readarray with index slicing.
#
#Wait, but if we want portability, maybe avoid process substitution? But instructions say "self-contained Bash script" so it's likely that we assume bash is available and a typical completion environment uses bash-completion system. Possibly I'll do:
#  lines=($out)
#But careful: The first line is header, second lines are actual model names.
#  
#I can then iterate from index 1 onward.
#
#I'll produce code:
#
#_ollama_run_completion() {
#    # We need to complete the <model> argument only if at least three words have been typed.
#    if [[ $COMP_CWORD -le 2 ]]; then
#         return
#    fi
#
#    local models=()
#    local out
#    out=$(ollama list 2>/dev/null || true)
#    # If output is empty, do nothing.
#    if [[ -z "$out" ]]; then
#         return
#    fi
#
#    # Split into lines. We can use IFS newlines and read array.
#    # This works in bash:
#    local line
#    while IFS= read -r line; do
#       # Skip header (line "NAME ID SIZE MODIFIED") if it matches
#       if [[ "$line" == NAME* ]]; then
#           continue
#       fi
#       # Extract first column using parameter expansion?
#       # We assume model names are first token. 
#       models+=("${line%% *}")  # This extracts up to the first space.
#    done <<< "$out"
#
#    COMPREPLY=( $(compgen -W "${models[*]}" -- "${COMP_WORDS[2]}") )
#}
#
#That is a nice solution, using bash parameter expansion ${line%% *} which means "remove trailing characters starting with space". That is portable in bash. I'll do that.
#
#I need to output a complete script with comments and installation snippet. The file should be self-contained so it defines the function _ollama_run_completion, maybe register it for command ollama run completion by using complete -F _ollama_run_completion ollama run ?
#
#But instructions: "Your solution must be a self-contained Bash script. Only the complete script with comments and installation snippet." That means I'll include instructions like:
#  # Installation snippet:
#  # For bash-completion, add:
#  #   if [ -f /etc/bash_completion ]; then
#  #       . /etc/bash_completion
#  #   fi
#  #   complete -F _ollama_run_completion ollama run
#
#But it's a bit ambiguous: The script is to be self-contained and include the installation snippet. I'll produce code:
#  
##!/bin/bash
## Bash-completion function for "ollama run" command.
## This completion function dynamically lists available models by parsing output of `ollama list`.
#
#_ollama_run_completion() {
#    # Check if at least 3 words have been entered (ollama, run, model)
#    if [[ $COMP_CWORD -le 2 ]]; then
#        return
#    fi
#
#    local models=()
#    local out
#    # Run ollama list and capture output, silencing errors.
#    out=$(ollama list 2>/dev/null || true)
#
#    # If no output, exit gracefully.
#    if [[ -z "$out" ]]; then
#        return
#    fi
#
#    # Parse the output: skip header line starting with NAME (e.g., "NAME ID SIZE MODIFIED")
#    local line#    while IFS= read -r line; do
#        # Skip header lines. Assume header starts with "NAME".
#        if [[ "$line" == NAME* ]]; then
#            continue
#        fi#
#        # Extract the first word from each line as the model name.
#        models+=("${line%% *}")  # Remove everything after first space.
#    done <<< "$out"
#
#    # Generate completion list using compgen with available models.
#    COMPREPLY=( $(compgen -W "${models[*]}" -- "${COMP_WORDS[2]}") )
#}
#
## Installation snippet:
## To install, add the following line to your ~/.bashrc or source this script directly:
##
##   complete -F _ollama_run_completion ollama run
##
## This sets up bash-completion for "ollama run <model>" command.
#  
#That's a complete solution.
#
#I'll produce final output in plain text with comments as required. Use "echo" if needed? No, it's self-contained script that registers the completion function.
#
#I'll also include header: "#!/bin/bash", etc.
#
#I'll produce final answer accordingly.
#
#I'll check if I have any issues:
#- The script is self-contained bash completion function.
#- It uses while read -r line; do ... done <<< "$out" which is portable to bash. (POSIX compliance: not strictly POSIX but it's in bash.)
#- It uses parameter expansion ${line%% *} to get first token of each line. That is a good solution.
#
#I'll include the installation snippet commented out at the end of the file.
#
#I must produce only complete script with comments and no extra text as instructions say "Only the complete script with comments and the installation snippet".
#
#I'll output final answer accordingly in plain text.
#</think>
#!/bin/bash
# Bash-completion function for the command: ollama run <model>
# This function dynamically retrieves available models by parsing the output of `ollama list`.
#
# The completion will trigger only when at least three words are entered:
#   1: "ollama"
#   2: "run"
#   3: <model> (the one being completed)

_ollama_run_completion() {
	# Only complete if we have a model argument (i.e. COMP_CWORD >= 3)
	if [[ $COMP_CWORD -le 2 ]]; then
		return
	fi

	local models=()
	local out

	# Capture output of "ollama list", ignoring errors.
	out=$(ollama list 2>/dev/null || true)

	# If no output is returned, exit gracefully.
	if [[ -z "$out" ]]; then
		return
	fi

	# Parse the output line by line.
	# The first line (the header) typically starts with "NAME", so we skip it.
	local line
	while IFS= read -r line; do
		# Skip header lines that start with "NAME"
		if [[ "$line" == NAME* ]]; then
			continue
		fi

		# Extract the first word from each line as the model name.
		# This works even if there are spaces in the rest of the line.
		models+=("${line%% *}")
	done <<< "$out"

	# Use compgen to generate completion suggestions for the model argument.
	COMPREPLY=( $(compgen -W "${models[*]}" -- "${COMP_WORDS[2]}") )
}

# Installation snippet:
#
# To enable this bash-completion, add the following line to your ~/.bashrc
# or source this script directly in your shell environment:
#
#   complete -F _ollama_run_completion ollama run
#
# This registers the _ollama_run_completion function for "ollama run <model>" completions.
#
# End of script.
