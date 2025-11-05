# SECURITY ANALYSIS: Code appears safe - no dangerous operations detected
# - No privilege escalation attempts
# - No unauthorized file writes
# - Only reads from ollama command output
# - Standard bash completion functionality

#!/bin/bash
_ollama_completions() {
	# Only complete if we're calling 'ollama' and the subcommand requires a model.
	if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
		COMPREPLY=(); return;
	fi

	# For commands that expect a <MODEL> argument, allow completion only for these:
	case "${COMP_WORDS[1]}" in
		show|run|stop|push|cp|rm)
			;;
		*)
			COMPREPLY=(); return;
	esac

	# Ensure the 'ollama' command is available.
	if ! command -v ollama &>/dev/null; then
		COMPREPLY=(); return;
	fi

	local cur prev
	_get_comp_words_by_ref -n : cur prev

	# Get the list of models from "ollama list" (skip header line).
	local models
	models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
	if [[ -z "$models" ]]; then
		COMPREPLY=(); return;
	fi

	# Generate completion matches against the current word.
	COMPREPLY=( $(compgen -W "$models" -- "$cur") )

	# Sort completions alphabetically.
	COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )

	__ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# To use:
# • Source this script in your shell's initialization file.
# • When you type "ollama <show|run|stop|push|cp|rm> ..." and press TAB,
#   the function will complete using the output of "ollama list".