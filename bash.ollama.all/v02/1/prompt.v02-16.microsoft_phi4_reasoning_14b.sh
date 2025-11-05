# [[HUMAN COMMENTED-OUT]]
#<think>We are Phi and we must produce a Bash script with a single bash function called _ollama_completions. It is a completion script for "ollama" command line tool that supports some commands. The prompt includes detailed instructions in structured format: "Generate a Bash Completion Script for ollama". It says the tasks should be grouped by commands. Commands to support:
#
#Group 1: Commands requiring <MODEL> completion:
#- show
#- run
#- stop
#- push
#- cp
#- rm
#
#Group 2: Command with special flag completions:
#- create (completes flags: --file, -f, --quantize, -q)
#
#Group 3: Commands with no argument completion:
#- serve
#- pull
#- signin
#- signout
#- list
#- ps
#- help
#
#And then "Functional Requirements" are:
#The script must be in a single function _ollama_completions. It uses case statement switching on the subcommand. Top-level completion: If previous word is "ollama", provide list of all subcommands as completions.
#
#For commands in group 1, we need to implement specific steps for model name completion:
#- Step A: Extract Word Info
#```
#local cur prev
#_get_comp_words_by_ref -n : cur prev
##- Step B: Fetch Models. Check if command "ollama" exists, then call ollama list and tail to skip header line then awk print $1 into local variable models. Then check empty models.
#The code:
#```
#if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#local models
#models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#[[ -z "$models" ]] && { COMPREPLY=(); return; }
#```
#- Step C: Generate Completions. Use compgen to generate completions.
#```
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#```
#- Step D: Sort and Trim. Then sort completions and then call __ltrim_colon_completions.
#
#We must not use arrays to store list of models, i.e. "models" variable is a string.
#We must not add fallback logic or check COMP_CWORD.
#Do not check for existence of _get_comp_words_by_ref or __ltrim_colon_completions.
#And do not sort the models before passing them to compgen.
#
#Also final output rules:
#- Output only raw Bash code
#- Do not include markdown, explanations, fences (like ```bash```).
#- Add brief inline comments to explain key parts of code.
#- Register the completion function at the end with "complete -F _ollama_completions ollama".
#
#Plan: We'll produce a function called _ollama_completions. The function will be in bash and must check if previous word is "ollama" then provide list of completions for subcommands. So the function structure:
#
#```
#_ollama_completions() {
#   # Determine current word & previous word
#   local cur prev
#   _get_comp_words_by_ref -n : cur prev
#   
#   # Top-level: if prev == "ollama", complete subcommands
#   case "$prev" in
#      ollama)
#         COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
#         return 0;;
#   esac
#
#   # Check which subcommand we are completing:
#   case "$prev" in
#       show|run|stop|push|cp|rm)
#           # Extract current word and previous word
#           local cur prev
#           _get_comp_words_by_ref -n : cur prev
#           
#           if ! command -v ollama &>/dev/null; then 
#              COMPREPLY=(); return; fi
#
#           local models
#           models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#           [[ -z "$models" ]] && { COMPREPLY=(); return; }
#           # Generate completions for model names
#           COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#           # Sort completions and trim colons
#           COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
#           __ltrim_colon_completions "$cur"
#           return 0;;
#       
#       create)
#           # For create command, complete flags: --file -f --quantize -q
#           local cur prev
#           _get_comp_words_by_ref -n : cur prev
#           
#           COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
#           return 0;;
#       
#       serve|pull|signin|signout|list|ps|help)
#           # For these commands, no argument completions are needed.
#           return 0;;
#   esac
#}
#```
#But careful: the original structure requires that top-level completion if previous word equals "ollama", then list all subcommands. Then use case switching on the command? But note that we already did a case for prev equal to "ollama". For group commands that require model names, they need special steps.
#
#But instructions say:
#"Group the commands by their completion behavior." So we have three groups:
#- Group 1: show, run, stop, push, cp, rm. These are completed with model name completions.
#- Group 2: create. This should complete flags: --file, -f, --quantize, -q
#- Group 3: serve, pull, signin, signout, list, ps, help. They require no argument completions.
#
#I need to produce a function _ollama_completions which does the following:
#1. Get previous word and current word.
#2. if previous word equals "ollama", then complete subcommands from all groups: "show run stop push cp rm create serve pull signin signout list ps help" but note that group 3 has no arguments completion so maybe just listing them is enough.
#
#But instructions says:
#"Top-level Completion: If the previous word is ollama, provide a list of all subcommands as completions." So we produce compgen -W "..." with all these subcommands.
#I need to include inline comments on key parts. And then at the end, register it using complete -F _ollama_completions ollama.
#
#Now check: For group 1, do special steps:
#- Extract word info: local cur prev; then _get_comp_words_by_ref -n : cur prev.
#But note that this part is already done outside in top-level completion. But instructions say for each case of subcommand, we need to extract word info again? Possibly because the function might be called repeatedly with different value for prev? However, I'll implement as required.
#
#I must also check for "ollama" command existence using "if ! command -v ollama &>/dev/null; then COMPREPLY=(); return;" So that's exactly what instructions say.
#
#Then assign local models to the output of "ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'". And if empty, set COMPREPLY=() and return. Then generate completions with compgen -W "$models" -- "$cur".
#Then sort and trim:
#COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
#__ltrim_colon_completions "$cur"
#
#I must not use arrays for models, so that's fine because models is a string.
#
#Now group 2: "create". For create command, we want to complete flags. So in the case block of "create", do local cur prev extraction, then generate completions with compgen -W "--file -f --quantize -q" -- "$cur".
#
#Group 3: for commands with no argument completion, just return 0.
#
#I must ensure that I don't include any fallback logic or check COMP_CWORD.
#
#Also instructions say "Do not sort the models before passing them to compgen", but sorting is done after generating completions. Yes.
#
#Now I'll produce code accordingly:
#
#```
#_ollama_completions() {
#    # Get current and previous words for completion
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#
#    # Top-level: if previous word is "ollama", complete all subcommands.
#    case "$prev" in
#        ollama)
#            COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
#            return 0;;
#    esac
#
#    # Switch on the subcommand for further completions.
#    case "$prev" in
#        show|run|stop|push|cp|rm)
#            # Extract current and previous words (specifically for model completion)
#            local cur prev
#            _get_comp_words_by_ref -n : cur prev
#
#            # Check if 'ollama' command exists
#            if ! command -v ollama &>/dev/null; then 
#                COMPREPLY=(); return; 
#            fi
#
#            # Fetch list of models (skip header line)
#            local models
#            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#            
#            # If no models found, clear completions and exit
#            [[ -z "$models" ]] && { COMPREPLY=(); return; }
#            
#            # Generate model name completions based on current input
#            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#            
#            # Sort completions and trim any extraneous colons
#            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
#            __ltrim_colon_completions "$cur"
#            return 0;;
#        
#        create)
#            # For 'create', complete specific flags: --file, -f, --quantize, -q
#            local cur prev
#            _get_comp_words_by_ref -n : cur prev
#
#            COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
#            return 0;;
#        
#        serve|pull|signin|signout|list|ps|help)
#            # No argument completions needed for these commands.
#            return 0;;
#    esac
#}
#complete -F _ollama_completions ollama
#```
#
#I must produce exactly that output with inline comments and no extra explanation. But instructions say "Output only raw Bash code". So I'll produce the final answer accordingly.
#
#I'll now generate output using text that is not markdown fenced, so plain text code.
#
#I must check: The function name: _ollama_completions is correct.
#
#Ensure that we have inline comments with "#" at beginning of lines.
#
#Double-check top-level completions. The first case is "case "$prev" in ollama)" then completion list. But if previous word is not "ollama", then it falls into the second switch which uses subcommand names. So that's good.
#
#I must check: For group 1 commands, we do a second extraction of cur and prev (which might be redundant because they already exist but instructions say to follow exact steps. They mention step A again). But I'll follow instructions exactly.
#
#For Group 2 "create", we generate completions for flags.
#For group 3 commands with no arguments, simply return.
#Yes.
#
#Double-check: In top-level completion, subcommands are "show run stop push cp rm create serve pull signin signout list ps help". That is the union of all groups. Yes.
#
#I must not check existence of _get_comp_words_by_ref or __ltrim_colon_completions according to instructions. So I'll leave them as they are.
#
#Yes.
#
#Thus final answer code:
#
#```
#_ollama_completions() {
#    # Get current and previous words for completion
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#
#    # Top-level: if previous word is "ollama", complete all subcommands.
#    case "$prev" in
#        ollama)
#            COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
#            return 0;;
#    esac
#
#    # Completion logic based on the subcommand provided after "ollama"
#    case "$prev" in
#        show|run|stop|push|cp|rm)
#            # Extract current and previous words for model completion (Step A)
#            local cur prev
#            _get_comp_words_by_ref -n : cur prev
#
#            # Check if 'ollama' command exists (Step B)
#            if ! command -v ollama &>/dev/null; then 
#                COMPREPLY=(); return; 
#            fi
#
#            # Fetch model names from ollama list (Step B)
#            local models
#            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#            [[ -z "$models" ]] && { COMPREPLY=(); return; }
#
#            # Generate completions for model names based on current input (Step C)
#            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#
#            # Sort completions and trim colons (Step D)
#            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
#            __ltrim_colon_completions "$cur"
#            return 0;;
#        
#        create)
#            # For 'create', complete specific flags (--file, -f, --quantize, -q)
#            local cur prev
#            _get_comp_words_by_ref -n : cur prev
#
#            COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
#            return 0;;
#        
#        serve|pull|signin|signout|list|ps|help)
#            # No argument completions for these commands.
#            return 0;;
#    esac
#}
#complete -F _ollama_completions ollama
#```
#
#I'll produce this as final answer.</think>

_ollama_completions() {
    # Get current and previous words for completion
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Top-level: if the previous word is "ollama", complete all subcommands.
    case "$prev" in
        ollama)
            COMPREPLY=( $(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur") )
            return 0;;
    esac

    # Completion logic based on the subcommand provided after "ollama"
    case "$prev" in
        show|run|stop|push|cp|rm)
            # Extract current and previous words for model completion (Step A)
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Check if the 'ollama' command exists (Step B)
            if ! command -v ollama &>/dev/null; then 
                COMPREPLY=(); return; 
            fi

            # Fetch model names from "ollama list" (skip header) (Step B)
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Generate completions for model names based on current input (Step C)
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )

            # Sort completions and trim any extraneous colons (Step D)
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            return 0;;
        
        create)
            # For 'create', complete specific flags (--file, -f, --quantize, -q)
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
            return 0;;
        
        serve|pull|signin|signout|list|ps|help)
            # No argument completions for these commands.
            return 0;;
    esac
}

complete -F _ollama_completions ollama
