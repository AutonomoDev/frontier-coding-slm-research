#!/bin/bash
# Bash completion for 'ollama run <model>'

_ollama_run_model() {
	# Get current word (cur) and previous word (prev)
	local cur prev
	if declare -F _get_comp_words_by_ref >/dev/null 2>&1; then
		_get_comp_words_by_ref cur prev
	else
		cur="${COMP_WORDS[COMP_CWORD]}"
		prev="${COMP_WORDS[COMP_CWORD-1]}"
	fi

	# Only complete if the previous word is 'run'
	if [[ "$prev" != "run" ]]; then
		return 0
	fi

	# Retrieve the model list from 'ollama list' and capture its output.
	local models
	models=$(ollama list 2>/dev/null)
	
	# If retrieval fails or returns an empty string, exit gracefully.
	if [[ -z "$models" ]]; then
		return 0
	fi

	# Split the retrieved models into an array (without invoking a subshell).
	local -a model_list
	while IFS= read -r line; do
		model_list+=("$line")
	done <<< "$models"

	# Filter out only those models that start with the current prefix.
	local -a matches
	for m in "${model_list[@]}"; do
		if [[ "$m" == "$cur"* ]]; then
			matches+=("$m")
		fi
	done

	# Sort the matching models alphabetically using GNU sort.
	readarray -t sorted_matches <<< "$(printf "%s\n" "${matches[@]}" | sort)"

	# Populate COMPREPLY with the sorted completions.
	COMPREPLY=( $(compgen -W "$(printf "%s\n" "${sorted_matches[@]}")" -- "$cur" ) )
}

# Attach the completion function to 'ollama'
complete -F _ollama_run_model ollama

# Installation Instructions:
# Save this script as, for example, /etc/bash_completion.d/ollama_run_model.
# Then add the following line to your .bashrc:
#   source /etc/bash_completion.d/ollama_run_model
# Reload your shell (e.g., exec bash) to activate.
