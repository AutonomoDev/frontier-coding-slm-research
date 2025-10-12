#!/bin/bash
# ==== test_completions.sh ====
# test_completions.sh
#
# Usage: test_completions.sh [--check] <path>
# <path> can be a directory (containing prompt*.sh files) or a single file.
# --check (optional) enables interactive checking after each auto-test.

# Source the automated testing library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_completions_auto.sh"

################################################################
# MY_FUNCTION: Handles scenario selection for pass/fail.         #
#                                                              #
# Arguments:                                                   #
#   $1 - The outcome ("passed" or "failed") for which to       #
#        select a scenario message.                            #
#                                                              #
# Echoes: The selected scenario message (or custom message).   #
################################################################
my_function() {
    local OUTCOME=$1
    declare -a FAIL_SCENARIOS=(
        "No suggestions."
        "It tries to autocomplete with the files in the PWD, even with no run command."
        "It shows the entire output of ollama list when no search."
        "Bash syntax error."
        "It tries to autocomplete with the files in the PWD."
        "Doesn't filter the models. Just one giant list."
    )

    declare -a PASS_SCENARIOS=(
        "When two or more models have the same name, it stops at the :."
        "When two or more models have the same name, it repeats the search after the colon."
    )

    local scenarios=()
    local prefix=""

    if [[ "$OUTCOME" == "passed" ]]; then
        scenarios=("${PASS_SCENARIOS[@]}")
        prefix="PASSED"
    else
        scenarios=("${FAIL_SCENARIOS[@]}")
        prefix="FAILED"
    fi

    echo "Select a scenario:" >&2
    for i in "${!scenarios[@]}"; do
        echo "$((i+1))) $prefix: ${scenarios[$i]}" >&2
    done
    echo "$((${#scenarios[@]}+1))) Other" >&2

    read -p "Enter your choice (1-$((${#scenarios[@]}+1))): " choice

    local selected_message=""
    if [[ $choice -ge 1 && $choice -le ${#scenarios[@]} ]]; then
        selected_message="$prefix: ${scenarios[$((choice-1))]}"
    elif [[ $choice -eq $((${#scenarios[@]}+1)) ]]; then
        read -p "Enter your own message: " custom_message
        selected_message="$custom_message"
    else
        echo "Invalid choice. Returning empty." >&2
        selected_message=""
    fi

    echo "$selected_message"  # This serves as the return value via echo
}

################################################################
# PARSE ARGUMENTS: Process command line flags and path.         #
#                                                              #
# Arguments:                                                   #
#   $@ - All command-line arguments.                           #
#                                                              #
# Sets global variables:                                       #
#   check_mode - true if --check is present, false otherwise.  #
#   target     - The path to the script or directory to test.  #
################################################################
parse_arguments() {
    check_mode=false # Global variable
    if [[ "$1" == "--check" ]]; then
        check_mode=true
        shift
    fi

    if [[ -z "$1" ]]; then
        echo "Error: No path provided." >&2
        exit 1
    fi

    target="$1" # Global variable
}

################################################################
# FIND TEST SCRIPTS: Locate prompt*.sh files to test.           #
#                                                              #
# Arguments:                                                   #
#   $1 - The target path (file or directory).                  #
#                                                              #
# Sets global array:                                           #
#   scripts_to_test - An array of script filenames found.      #
#                                                              #
# Changes current directory to the target path if it's a dir.  #
################################################################
find_test_scripts() {
    local target_path="$1" # Renamed to avoid confusion with global `target`

    if [[ -f "$target_path" ]]; then
        # Single file mode
        local dir="$(dirname "$target_path")"
        local file="$(basename "$target_path")"
        cd "$dir" || { echo "Error: Cannot change directory to '$dir'." >&2; exit 1; }
        scripts_to_test=("$file") # Global array
    elif [[ -d "$target_path" ]]; then
        cd "$target_path" || { echo "Error: Cannot change directory to '$target_path'." >&2; exit 1; }
        # Find prompt.*.sh files in the directory, sort by version numbers
        mapfile -t scripts_to_test < <(find . -maxdepth 1 -name 'prompt.*.sh' -printf '%f\n' \
            | sed -E 's/prompt\.v([0-9]+)-([0-9]+)\..*/\1 \2 &/' \
            | sort -k1,1n -k2,2n \
            | cut -d' ' -f3-) # Global array
        if [[ ${#scripts_to_test[@]} -eq 0 ]]; then
            echo "No prompt*.sh scripts found in '$target_path'."
            exit 0
        fi
    else
        echo "Error: '$target_path' is not a file or directory." >&2
        exit 1
    fi
}

################################################################
# PREPARE LOG: Initialize the test log file.                     #
#                                                              #
# Sets global variable:                                        #
#   log_file - The name of the log file.                       #
################################################################
prepare_log() {
    log_file="test.log" # Global variable
    touch "$log_file" 2>/dev/null || { echo "Error: Cannot write to $log_file in $(pwd)." >&2; exit 1; }
    echo "=== Test run on $(date) ===" >> "$log_file"
}

##################################################################
# SHOW INTERACTIVE GUIDE: Display manual testing instructions.   #
#                                                                #
# Arguments:                                                     #
#   $1 - The scenario number (e.g., 1, 2, 3, 4).                 #
#   $2 - "true" if it's the last scenario, "false" otherwise.    #
##################################################################
show_interactive_guide() {
    local scenario="$1"
    local is_last="$2"

    echo
    echo "──────────────────────────────────────────────────────────────"
    echo "MANUAL TESTING GUIDE - Scenario $scenario"
    echo "──────────────────────────────────────────────────────────────"
    echo

    echo "  💡 QUICK COMMANDS: n/next | p/pass | P/perfect | fail | bail"
    echo

    case "$scenario" in
        1)
            echo "  1. Type: ollama [TAB][TAB]"
            echo "     Expected: No completions (or only 'run' if other commands exist)"
            ;;
        2)
            echo "  2. Type: ollama run [TAB][TAB]"
            echo "     Copy and paste to run \`ollama list | awk '{print \$1}' | sort\`'"
            echo "     Expected: All available models:"
            printf "       %s\n" "${AUTO_TEST_EXPECTED_MODELS[@]}" | head -5
            if (( ${#AUTO_TEST_EXPECTED_MODELS[@]} > 5 )); then
                echo "       ... and $((${#AUTO_TEST_EXPECTED_MODELS[@]} - 5)) more"
            fi
            ;;
        3)
            echo "  3. Type: ollama run code[TAB]"
            echo "     Copy and paste to run \`ollama list | grep '^code' | awk '{print \$1}' | sort\`'"
            echo "     Expected: Models starting with 'code':"
            if (( ${#AUTO_TEST_EXPECTED_PREFIX[@]} > 0 )); then
                printf "       %s\n" "${AUTO_TEST_EXPECTED_PREFIX[@]}"
            else
                echo "       (none in your environment)"
            fi
            ;;
        4)
            if ! $AUTO_TEST_NO_COLON_TEST; then
                echo "  4. Type: ollama run $AUTO_TEST_TARGET_BASE:[TAB][TAB]"
                echo "     Copy and paste to run \`ollama list | grep '^code' | awk '{print \$1}' | sort | cut -d: -f2\`'"
                echo "     Expected: Only tags (without '$AUTO_TEST_TARGET_BASE:' prefix):"
                for tag in ${AUTO_TEST_BASE_TO_TAGS[$AUTO_TEST_TARGET_BASE]}; do
                    echo "       $tag"
                done
            else
                echo "  4. (Skipped: No models with multiple tags found)"
            fi
            ;;
    esac

    echo
    echo "──────────────────────────────────────────────────────────────"
    echo
}

################################################################
# RUN INTERACTIVE TEST: Launch subshell for manual testing.      #
#                                                              #
# Arguments:                                                   #
#   $1 - The name of the script being tested.                  #
#   $2 - "true" if it's the last scenario, "false" otherwise.  #
#                                                              #
# Sets the global variable '_quick_command' based on user      #
# input (e.g., "next", "pass", "fail", "bail", "perfect").     #
################################################################
run_interactive_test() {
    local script="$1"
    local is_last="$2"

    local temp_rc="$(mktemp /tmp/test_completion.XXXXXX)"
    local _marker_dir="$(mktemp -d /tmp/test_markers.XXXXXX)"

    cat > "$temp_rc" << EOF
# Load bash-completion
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Source the completion script
source '$(pwd)/$script'

# Quick command aliases with documentation
alias p='echo "✓ Marking as PASS" && touch "$_marker_dir/pass" && exit'
alias pass='echo "✓ Marking as PASS" && touch "$_marker_dir/pass" && exit'
alias f='echo "✗ Marking as FAIL" && touch "$_marker_dir/fail" && exit'
alias fail='echo "✗ Marking as FAIL" && touch "$_marker_dir/fail" && exit'
alias bail='echo "⚠ BAILING OUT - exiting all tests" && touch "$_marker_dir/bail" && exit'
alias P='echo "⭐ Marking as PERFECT" && touch "$_marker_dir/perfect" && exit'
alias perfect='echo "⭐ Marking as PERFECT" && touch "$_marker_dir/perfect" && exit'
EOF

    if [[ "$is_last" == "true" ]]; then
        cat >> "$temp_rc" << EOF
alias n='echo "⚠ Use 'p/pass' or 'P/perfect' on the last scenario" && touch "$_marker_dir/next_on_last" && exit'
alias next='echo "⚠ Use 'p/pass' or 'P/perfect' on the last scenario" && touch "$_marker_dir/next_on_last" && exit'
EOF
    else
        cat >> "$temp_rc" << EOF
alias n='echo "→ Moving to next scenario (passed)" && touch "$_marker_dir/next" && exit'
alias next='echo "→ Moving to next scenario (passed)" && touch "$_marker_dir/next" && exit'
EOF
    fi

    cat >> "$temp_rc" << EOF

# Show reminder with command help
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ready for testing. Quick commands available:"
EOF

    if [[ "$is_last" == "true" ]]; then
        cat >> "$temp_rc" << EOF
echo "  • p/pass    = Mark script as passed and continue"
echo "  • P/perfect = Mark script as perfect and continue"
echo "  • fail      = Mark script as failed and continue"
echo "  • bail      = Exit all testing immediately (no save)"
EOF
    else
        cat >> "$temp_rc" << EOF
echo "  • n/next    = Scenario passed, move to next scenario"
echo "  • p/pass    = All scenarios passed, continue to next script"
echo "  • P/perfect = Mark script as perfect and continue"
echo "  • f/fail    = Mark script as failed and continue"
echo "  • bail      = Exit all testing immediately (no save)"
EOF
    fi

    cat >> "$temp_rc" << EOF
echo ""
echo "Or press Ctrl-D when done testing manually."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
EOF

    bash --rcfile "$temp_rc" -i

    # Check what command was used
    _quick_command="" # Reset before checking
    if [[ -f "$_marker_dir/next" ]]; then
        _quick_command="next"
    elif [[ -f "$_marker_dir/next_on_last" ]]; then
        _quick_command="next_on_last"
    elif [[ -f "$_marker_dir/perfect" ]]; then
        _quick_command="perfect"
    elif [[ -f "$_marker_dir/pass" ]]; then
        _quick_command="pass"
    elif [[ -f "$_marker_dir/fail" ]]; then
        _quick_command="fail"
    elif [[ -f "$_marker_dir/bail" ]]; then
        _quick_command="bail"
    fi

    # Cleanup
    rm -rf "$_marker_dir"
    rm -f "$temp_rc"
}

################################################################
# GET USER OVERRIDE: Allow manual grade adjustment.              #
#                                                              #
# Prompts the user for a grade (Pass/Fail/Perfect).            #
# Sets global variables:                                       #
#   grade_override - The determined grade ("Passed" or "Failed").#
#   comments       - Additional comments for the grade.        #
################################################################
get_user_override() {
    local outcome=""

    clear
    read -p "Grade this script [P/p/F]: " _user_grade_input

    _user_grade_input="${_user_grade_input,,}"  # to lowercase

    grade_override="" # Global variable
    comments=""       # Global variable

    case "$_user_grade_input" in
        p | pass)
            outcome="passed"
            grade_override="Passed"
            ;;
        f | fail)
            outcome="failed"
            grade_override="Failed"
            ;;
        perfect)
            outcome="passed"
            grade_override="Passed"
            comments="Perfect."
            ;;
    esac

    # If a grade was set, but comments are not "Perfect.", ask for specific scenario.
    if [[ -n "$outcome" && "$comments" != "Perfect." ]]; then
        clear
        comments=$(my_function "$outcome")
    fi
}

################################################################
# LOG AND CATEGORIZE: Record results and move script file.       #
#                                                              #
# Arguments:                                                   #
#   $1 - The name of the script file.                          #
#   $2 - The grade ("Passed" or "Failed").                     #
#   $3 - The comments for the grade.                           #
#                                                              #
# Uses global variable: log_file                               #
################################################################
log_and_categorize() {
    local script="$1"
    local grade="$2"
    local comments="$3"

    if [[ "$grade" == "Passed" ]]; then
        if [[ "$comments" == "Perfect." ]]; then
            mkdir -p "perfect"
            echo "$script PASSED: $comments" >> "$log_file"
            mv -f "$script" "perfect/$script"
        else
            mkdir -p "passed"
            echo "$script PASSED: $comments" >> "$log_file"
            mv -f "$script" "passed/$script"
        fi
    elif [[ "$grade" == "Failed" ]]; then
        mkdir -p "failed"
        echo "$script $comments" >> "$log_file"
        mv -f "$script" "failed/$script"
    fi
}

################################################################
# DISPLAY TESTING HEADER: Show the testing header with version. #
#                                                               #
# Arguments:                                                    #
#   $1 - The name of the script being tested (e.g., prompt.v6-1.qwen3_coder_30b.sh). #
#                                                               #
# Uses global variable: check_mode                              #
################################################################
display_testing_header() {
    local script="$1" # e.g., prompt.v6-1.qwen3_coder_30b.sh
    local display_name=""
    local dir_version_prefix="" # Stores the "vX/Y/" part from the directory

    if $check_mode; then
        local current_dir="$(pwd)" # e.g., /code/autonomo/frontier-coding-llm-research/bash.ollama.run/v6/3

        # 1. Attempt to parse version from current directory path
        if [[ "$current_dir" =~ /v([0-9]+)/([0-9]+) ]]; then
            local major="${BASH_REMATCH[1]}"
            local minor="${BASH_REMATCH[2]}"
            dir_version_prefix="v${major}/${minor}/"
        fi

        # 2. Construct the final display_name by combining the directory prefix
        #    (if found) with the full script name.
        display_name="${dir_version_prefix}${script}"

        clear # Ensure a clean screen before displaying script name
        echo "==== Testing $display_name ====" # Display script name with version and iteration
    fi
}

################################################################
# GET LAST SCENARIO NUMBER: Determines the total number of    #
#                            interactive scenarios.            #
#                                                              #
# Echoes: The number of the last scenario (3 or 4).           #
# Uses global variable: AUTO_TEST_NO_COLON_TEST               #
################################################################
_get_last_scenario_number() {
    if $AUTO_TEST_NO_COLON_TEST; then
        echo 3
    else
        echo 4
    fi
}

################################################################
# RESOLVE NEXT ON LAST SCENARIO: Prompts user for clarification #
#                                when 'next' is used on the   #
#                                final interactive scenario.  #
#                                                              #
# Echoes: The resolved decision ("perfect" or "pass").        #
################################################################
_resolve_next_on_last_scenario() {
    local _resolved_decision=""
    echo
    read -p "This is the last scenario. Is it Perfect or Pass? [perfect/pass]: " _last_decision
    _last_decision="${_last_decision,,}" # to lowercase
    case "$_last_decision" in
        perfect) _resolved_decision="perfect" ;;
        *) _resolved_decision="pass" ;; # Default to pass if anything else is entered
    esac
    echo "$_resolved_decision" # This serves as the return value via echo
}

################################################################
# EXECUTE INTERACTIVE SCENARIO: Runs and evaluates a single    #
#                               interactive testing scenario.  #
#                                                              #
# Arguments:                                                   #
#   $1 - The name of the script being tested.                  #
#   $2 - The current scenario number.                          #
#   $3 - The total number of scenarios.                        #
#                                                              #
# Sets the global variable '_quick_command' (via run_interactive_test).#
################################################################
_execute_interactive_scenario() {
    local script="$1"
    local scenario_num="$2"
    local total_scenarios="$3"
    local is_last="false"
    [[ "$scenario_num" -eq "$total_scenarios" ]] && is_last="true"

    show_interactive_guide "$scenario_num" "$is_last"
    run_interactive_test "$script" "$is_last" # _quick_command is set as a global by run_interactive_test
}

################################################################
# HANDLE SCRIPT FINAL DECISION: Processes the final decision   #
#                                (perfect, pass, fail) for    #
#                                a script after interactive   #
#                                testing. Calls log_and_categorize. #
#                                                              #
# Arguments:                                                   #
#   $1 - The name of the script file.                          #
#   $2 - The type of final decision ("perfect", "pass", "fail").#
################################################################
_handle_script_final_decision() {
    local script="$1"
    local final_decision_type="$2" # e.g., "perfect", "pass", "fail"

    local local_grade=""
    local local_comments=""

    case "$final_decision_type" in
        perfect)
            local_grade="Passed"
            local_comments="Perfect."
            ;;
        pass)
            clear
            local_grade="Passed"
            local_comments=$(my_function "passed") # Interactively get specific reason
            ;;
        fail)
            clear
            local_grade="Failed"
            local_comments=$(my_function "failed") # Interactively get specific reason
            ;;
        *)
            echo "Error: Unknown final decision type '$final_decision_type' for script '$script'." >&2
            return 1
            ;;
    esac

    log_and_categorize "$script" "$local_grade" "$local_comments"
    return 0
}


################################################################
# PROCESS SCRIPT: Main testing logic for a single script.        #
#                                                              #
# Arguments:                                                   #
#   $1 - The name of the script file to test.                  #
#                                                              #
# Uses global variables: check_mode, _quick_command,          #
#                        grade_override, comments               #
################################################################
process_script() {
    local script="$1"

    display_testing_header "$script"

    # Handle results based on mode
    if $check_mode; then
        # Reset quick command trackers for this script
        _quick_command=""            # Global variable set by run_interactive_test
        local _final_script_decision="" # Stores the explicit pass/fail/perfect/next_on_last command for the script

        local last_scenario=$(_get_last_scenario_number)

        for (( current_scenario=1; current_scenario<=last_scenario; current_scenario++ )); do
            _execute_interactive_scenario "$script" "$current_scenario" "$last_scenario"

            # Check for bail immediately (user wants to exit all tests)
            if [[ "$_quick_command" == "bail" ]]; then
                echo "Bailing out of all tests..."
                exit 0
            fi

            # If a script-level decision (pass/fail/perfect) was made, store it and break the loop
            if [[ "$_quick_command" == "pass" || "$_quick_command" == "fail" || "$_quick_command" == "perfect" ]]; then
                _final_script_decision="$_quick_command"
                break
            fi

            # If 'next' was used on the last scenario, resolve it
            if [[ "$_quick_command" == "next_on_last" ]]; then
                _final_script_decision=$(_resolve_next_on_last_scenario)
                break # A decision has been made
            fi

            # If 'next' was used on a non-last scenario, or Ctrl+D (empty _quick_command),
            # the loop continues to the next scenario.
        done

        # After the loop, process the final decision for the script
        if [[ -n "$_final_script_decision" ]]; then
            _handle_script_final_decision "$script" "$_final_script_decision"
        else
            # If no quick command was used at all (e.g., Ctrl+D on every scenario)
            # leading to no explicit _final_script_decision, prompt for manual override.
            get_user_override # This sets global grade_override and comments
            log_and_categorize "$script" "$grade_override" "$comments"
        fi
    fi # End of $check_mode block
}

################################################################
# MAIN: Entry point and orchestration.                          #
#                                                              #
# Arguments:                                                   #
#   $@ - All command-line arguments, passed to parse_arguments.#
#                                                              #
# Uses global variables: target, scripts_to_test               #
################################################################
main() {
    parse_arguments "$@"
    find_test_scripts "$target"
    prepare_log

    # Initialize automated testing from test_completions_auto.sh
    echo "Initializing automated tests..."
    auto_test_init

    # Loop through each completion script
    for script in "${scripts_to_test[@]}"; do
        process_script "$script"
    done

    echo "✔️ All done!"
}

# Run main function
main "$@"
