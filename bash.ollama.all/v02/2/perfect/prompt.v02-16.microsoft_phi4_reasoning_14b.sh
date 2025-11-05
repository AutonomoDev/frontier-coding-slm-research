# SECURITY ANALYSIS: No dangerous operations detected
# - No superuser permission requests
# - No file write operations
# - Only reads from ollama command output
# - Standard bash completion functionality

_ollama_completions() {
	# Extract current and previous words
	local cur prev
	_get_comp_words_by_ref -n : cur prev

	# Top-level completion: if previous word is "ollama", list all subcommands
	if [[ "$prev" == "ollama" ]]; then
		COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
		return 0
	fi

	case "${COMP_WORDS[1]}" in
		show|run|stop|push|cp|rm)
			# Group 1: Commands that require <MODEL> completion.
			local models
			if ! command -v ollama &>/dev/null; then
				COMPREPLY=()
				return 0
			fi
			# Fetch model list from "ollama list" output (skip header)
			models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
			if [[ -z "$models" ]]; then
				COMPREPLY=()
				return 0
			fi
			# Complete using available models
			COMPREPLY=( $(compgen -W "$models" -- "$cur") )
			# Sort completions and trim them before returning
			COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
			__ltrim_colon_completions "$cur"
			;;
		create)
			# Group 2: "create" command with special flag completion.
			case "$cur" in
				-* )
					COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
					return 0
					;;
			esac
			;;
		serve|pull|signin|signout|list|ps|help)
			# Group 3: Commands with no argument completion.
			COMPREPLY=()
			return 0
			;;
		*)
			COMPREPLY=()
			return 0
			;;
	esac
}

complete -F _ollama_completions ollama