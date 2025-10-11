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
################################################################
my_function() {
    local OUTCOME=$1
    declare -a FAIL_SCENARIOS=(
        "No suggestions."
        "It tries to autocomplete with the files in the PWD, even with no run command."
        "It shows the entire output of ollama list when no search."
        "The script completely fails to give any suggestions at all."
        "It tries to autocomplete with the files in the PWD."
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
################################################################
parse_arguments() {
    check_mode=false
    if [[ "$1" == "--check" ]]; then
        check_mode=true
        shift
    fi

    if [[ -z "$1" ]]; then
        echo "Error: No path provided." >&2
        exit 1
    fi

    target="$1"
}

################################################################
# FIND TEST SCRIPTS: Locate prompt*.sh files to test.           #
################################################################
find_test_scripts() {
    local target="$1"

    if [[ -f "$target" ]]; then
        # Single file mode
        dir="$(dirname "$target")"
        file="$(basename "$target")"
        cd "$dir" || { echo "Error: Cannot change directory to '$dir'." >&2; exit 1; }
        scripts_to_test=("$file")
    elif [[ -d "$target" ]]; then
        cd "$target" || { echo "Error: Cannot change directory to '$target'." >&2; exit 1; }
        # Find prompt.*.sh files in the directory, sort by version numbers
        mapfile -t scripts_to_test < <(find . -maxdepth 1 -name 'prompt.*.sh' -printf '%f\n' \
            | sed -E 's/prompt\.v([0-9]+)-([0-9]+)\..*/\1 \2 &/' \
            | sort -k1,1n -k2,2n \
            | cut -d' ' -f3-)
        if [[ ${#scripts_to_test[@]} -eq 0 ]]; then
            echo "No prompt*.sh scripts found in '$target'."
            exit 0
        fi
    else
        echo "Error: '$target' is not a file or directory." >&2
        exit 1
    fi
}

################################################################
# PREPARE LOG: Initialize the test log file.                     #
################################################################
prepare_log() {
    log_file="test.log"
    touch "$log_file" 2>/dev/null || { echo "Error: Cannot write to $log_file in $(pwd)." >&2; exit 1; }
    echo "=== Test run on $(date) ===" >> "$log_file"
}

##################################################################
# SHOW INTERACTIVE GUIDE: Display manual testing instructions.   #
##################################################################
show_interactive_guide() {
    local scenario="$1"
    local is_last="$2"

    echo
    echo "──────────────────────────────────────────────────────────────"
    echo "MANUAL TESTING GUIDE - Scenario $scenario"
    echo "──────────────────────────────────────────────────────────────"
    echo

    if [[ "$is_last" == "true" ]]; then
        echo "  💡 QUICK COMMANDS: n/next | p/pass | P/perfect | fail | bail"
    else
        echo "  💡 QUICK COMMANDS: n/next | p/pass | fail | bail"
    fi
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
################################################################
run_interactive_test() {
    local script="$1"
    local is_last="$2"

    temp_rc="$(mktemp /tmp/test_completion.XXXXXX)"
    _marker_dir="$(mktemp -d /tmp/test_markers.XXXXXX)"

    cat > "$temp_rc" << EOF
# Load bash-completion
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Source the completion script
source '$(pwd)/$script'

# Quick command aliases with documentation
alias p='echo "✓ Marking as PASS" && touch "$_marker_dir/pass" && exit'
alias pass='echo "✓ Marking as PASS" && touch "$_marker_dir/pass" && exit'
alias fail='echo "✗ Marking as FAIL" && touch "$_marker_dir/fail" && exit'
alias bail='echo "⚠ BAILING OUT - exiting all tests" && touch "$_marker_dir/bail" && exit'
EOF

    if [[ "$is_last" == "true" ]]; then
        cat >> "$temp_rc" << EOF
alias n='echo "⚠ Use 'p/pass' or 'P/perfect' on the last scenario" && touch "$_marker_dir/next_on_last" && exit'
alias next='echo "⚠ Use 'p/pass' or 'P/perfect' on the last scenario" && touch "$_marker_dir/next_on_last" && exit'
alias P='echo "⭐ Marking as PERFECT" && touch "$_marker_dir/perfect" && exit'
alias perfect='echo "⭐ Marking as PERFECT" && touch "$_marker_dir/perfect" && exit'
EOF
    else
        cat >> "$temp_rc" << EOF
alias n='echo "→ Moving to next scenario (passed)" && touch "$_marker_dir/next" && exit'
alias next='echo "→ Moving to next scenario (passed)" && touch "$_marker_dir/next" && exit'
alias P='echo "⚠ 'P' can only be used on the last scenario"'
alias perfect='echo "⚠ 'perfect' can only be used on the last scenario"'
EOF
    fi

    cat >> "$temp_rc" << EOF

# Show reminder with command help
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ready for testing. Quick commands available:"
EOF

    if [[ "$is_last" == "true" ]]; then
        cat >> "$temp_rc" << EOF
echo "  • p/pass  = Mark script as passed and continue"
echo "  • P/perfect = Mark script as perfect and continue"
echo "  • fail    = Mark script as failed and continue"
echo "  • bail    = Exit all testing immediately (no save)"
EOF
    else
        cat >> "$temp_rc" << EOF
echo "  • n/next  = Scenario passed, move to next scenario"
echo "  • p/pass  = All scenarios passed, continue to next script"
echo "  • fail    = Mark script as failed and continue"
echo "  • bail    = Exit all testing immediately (no save)"
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
    _quick_command=""
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
################################################################
get_user_override() {
    local outcome=""

    clear
    read -p "Grade this script [P/p/F]: " _user_grade_input

    _user_grade_input="${_user_grade_input,,}"  # to lowercase

    grade_override=""

    comments=""

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

    if [[ -n "$outcome" && "$comments" != "Perfect." ]]; then
        clear
        comments=$(my_function "$outcome")
    fi
}

################################################################
# LOG AND CATEGORIZE: Record results and move script file.       #
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
        echo "$script FAILED: $comments" >> "$log_file"
        mv -f "$script" "failed/$script"
    fi
}

################################################################
# PROCESS SCRIPT: Main testing logic for a single script.        #
################################################################
process_script() {
    local script="$1"

    if $check_mode; then
        clear # Ensure a clean screen before displaying script name
        echo "==== Testing $script ====" # Display script name
        sleep 1 # Briefly show the script name before clearing for the first scenario
    fi

    # Handle results based on mode
    if $check_mode; then
        # Reset quick command tracker
        _quick_command=""
        _final_decision=""          # Stores the explicit pass/fail/perfect command from interactive session
        _current_script_grade=""    # Stores the final grade for the current script
        _current_script_comments="" # Stores the final comments for the current script

        # Determine the last scenario
        local last_scenario
        if $AUTO_TEST_NO_COLON_TEST; then
            last_scenario=3
        else
            last_scenario=4
        fi

        # Show each scenario interactively
        local current_scenario=1
        show_interactive_guide 1 "false"
        run_interactive_test "$script" "false"

        # Check for bail immediately
        if [[ "$_quick_command" == "bail" ]]; then
            echo "Bailing out of all tests..."
            exit 0
        fi

        # If pass/fail used, record it and skip remaining tests
        if [[ "$_quick_command" == "pass" || "$_quick_command" == "fail" || "$_quick_command" == "perfect" ]]; then
            _final_decision="$_quick_command"
        fi

        # Continue with scenario 2 only if "next" was used or no decision made
        if [[ -z "$_final_decision" ]]; then
            current_scenario=2
            local is_last="false"
            [[ $current_scenario -eq $last_scenario ]] && is_last="true"

            show_interactive_guide 2 "$is_last"
            run_interactive_test "$script" "$is_last"

            if [[ "$_quick_command" == "bail" ]]; then
                echo "Bailing out of all tests..."
                exit 0
            fi

            if [[ "$_quick_command" == "next_on_last" ]]; then
                # User tried to use next on last scenario, ask for clarification
                echo
                read -p "This is the last scenario. Is it Perfect or Pass? [perfect/pass]: " _last_decision
                _last_decision="${_last_decision,,}"
                case "$_last_decision" in
                    perfect) _final_decision="perfect" ;;
                    *) _final_decision="pass" ;;
                esac
            elif [[ "$_quick_command" == "pass" || "$_quick_command" == "fail" || "$_quick_command" == "perfect" ]]; then
                _final_decision="$_quick_command"
            fi
        fi

        # Continue with scenario 3
        if [[ -z "$_final_decision" ]]; then
            current_scenario=3
            local is_last="false"
            [[ $current_scenario -eq $last_scenario ]] && is_last="true"

            show_interactive_guide 3 "$is_last"
            run_interactive_test "$script" "$is_last"

            if [[ "$_quick_command" == "bail" ]]; then
                echo "Bailing out of all tests..."
                exit 0
            fi

            if [[ "$_quick_command" == "next_on_last" ]]; then
                # User tried to use next on last scenario, ask for clarification
                echo
                read -p "This is the last scenario. Is it Perfect or Pass? [perfect/pass]: " _last_decision
                _last_decision="${_last_decision,,}"
                case "$_last_decision" in
                    perfect) _final_decision="perfect" ;;
                    *) _final_decision="pass" ;;
                esac
            elif [[ "$_quick_command" == "pass" || "$_quick_command" == "fail" || "$_quick_command" == "perfect" ]]; then
                _final_decision="$_quick_command"
            fi
        fi

        # Continue with scenario 4 if applicable
        if [[ -z "$_final_decision" ]] && ! $AUTO_TEST_NO_COLON_TEST; then
            current_scenario=4
            local is_last="true"

            show_interactive_guide 4 "$is_last"
            run_interactive_test "$script" "$is_last"

            if [[ "$_quick_command" == "bail" ]]; then
                echo "Bailing out of all tests..."
                exit 0
            fi

            if [[ "$_quick_command" == "next_on_last" ]]; then
                # User tried to use next on last scenario, ask for clarification
                echo
                read -p "This is the last scenario. Is it Perfect or Pass? [perfect/pass]: " _last_decision
                _last_decision="${_last_decision,,}"
                case "$_last_decision" in
                    perfect) _final_decision="perfect" ;;
                    *) _final_decision="pass" ;;
                esac
            elif [[ "$_quick_command" == "pass" || "$_quick_command" == "fail" || "$_quick_command" == "perfect" ]]; then
                _final_decision="$_quick_command"
            fi
        fi

        # Handle quick command if used
        if [[ "$_final_decision" == "perfect" ]]; then
            grade_override="Passed"
            comments="Perfect."
            log_and_categorize "$script" "$grade_override" "$comments"
            return
        elif [[ "$_final_decision" == "pass" ]]; then
            clear
            grade_override="Passed"
            comments=$(my_function "passed")
            log_and_categorize "$script" "$grade_override" "$comments"
            return
        elif [[ "$_final_decision" == "fail" ]]; then
            clear
            grade_override="Failed"
            comments=$(my_function "failed")
            log_and_categorize "$script" "$grade_override" "$comments"
            return
        fi

        # Show final grade (only if no quick decision was made)
        get_user_override
        log_and_categorize "$script" "$grade_override" "$comments"
    fi
}

################################################################
# MAIN: Entry point and orchestration.                          #
################################################################
main() {
    parse_arguments "$@"
    find_test_scripts "$target"
    prepare_log

    # Initialize automated testing
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
