#!/bin/bash
# test_completions.sh
#
# Usage: test_completions.sh [--check] <path>
# <path> can be a directory (containing prompt*.sh files) or a single file.
# --check (optional) enables interactive checking after each auto-test.

# Source the automated testing library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_completions_auto.sh"

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
    local result="$2"

    echo
    echo "──────────────────────────────────────────────────────────────"
    echo "MANUAL TESTING GUIDE - Scenario $scenario"
    echo "──────────────────────────────────────────────────────────────"
    echo

    case "$scenario" in
        1)
            echo "  1. Type: ollama [TAB][TAB]"
            echo "     Expected: No completions (or only 'run' if other commands exist)"
            if [[ -n "$result" ]]; then
                echo "     Auto-test got: $result"
            else
                echo "     Auto-test got: (no suggestions) ✓"
            fi
            ;;
        2)
            echo "  2. Type: ollama run [TAB][TAB]"
            echo "     Expected: All available models:"
            printf "       %s\n" "${AUTO_TEST_EXPECTED_MODELS[@]}" | head -5
            if (( ${#AUTO_TEST_EXPECTED_MODELS[@]} > 5 )); then
                echo "       ... and $((${#AUTO_TEST_EXPECTED_MODELS[@]} - 5)) more"
            fi
            if [[ -n "$result" ]]; then
                echo "     Auto-test got: ${result:0:60}..."
            else
                echo "     Auto-test got: (no suggestions) ✗"
            fi
            ;;
        3)
            echo "  3. Type: ollama run code[TAB]"
            echo "     Expected: Models starting with 'code':"
            if (( ${#AUTO_TEST_EXPECTED_PREFIX[@]} > 0 )); then
                printf "       %s\n" "${AUTO_TEST_EXPECTED_PREFIX[@]}"
            else
                echo "       (none in your environment)"
            fi
            if [[ -n "$result" ]]; then
                echo "     Auto-test got: $result"
            else
                echo "     Auto-test got: (no suggestions)"
            fi
            ;;
        4)
            if ! $AUTO_TEST_NO_COLON_TEST; then
                echo "  4. Type: ollama run $AUTO_TEST_TARGET_BASE:[TAB][TAB]"
                echo "     Expected: Only tags (without '$AUTO_TEST_TARGET_BASE:' prefix):"
                for tag in ${AUTO_TEST_BASE_TO_TAGS[$AUTO_TEST_TARGET_BASE]}; do
                    echo "       $tag"
                done
                if [[ -n "$result" ]]; then
                    echo "     Auto-test got: $result"
                    if [[ "$result" == *":"* ]]; then
                        echo "     Note: Still contains colons (not perfect)"
                    else
                        echo "     Note: Clean tags only ✓"
                    fi
                else
                    echo "     Auto-test got: (no suggestions) ✗"
                fi
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

    temp_rc="$(mktemp /tmp/test_completion.XXXXXX)"
    cat > "$temp_rc" << EOF
# Load bash-completion
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# Source the completion script
source '$(pwd)/$script'

# Show reminder
echo "Ready for testing. Type 'exit' or press Ctrl-D when done."
echo
EOF
    bash --rcfile "$temp_rc" -i
    rm -f "$temp_rc"
}

################################################################
# GET USER OVERRIDE: Allow manual grade adjustment.              #
################################################################
get_user_override() {
    local grade="$1"
    local reason="$2"

    echo
    read -p "Auto-graded as $grade. Press Enter to accept, or type new grade [P/p/F]: " _user_grade_input
    _user_grade_input="${_user_grade_input,,}"  # to lowercase
    grade_override="$grade"
    comments="$reason"
    if [[ -n "$_user_grade_input" ]]; then
        case "$_user_grade_input" in
            p | pass)
                grade_override="Passed"
                read -p "Comments: " -r _comments_input
                [[ -z "$_comments_input" ]] && comments="$reason" || comments="$_comments_input"
                ;;
            f | fail)
                grade_override="Failed"
                read -p "Comments: " -r _comments_input
                [[ -z "$_comments_input" ]] && comments="$reason" || comments="$_comments_input"
                ;;
            perfect)
                grade_override="Passed"
                comments="Perfect."
                ;;
        esac
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
        clear
    fi
    echo "==== Testing $script ===="

    # Run automated tests
    if ! auto_test_run "$script"; then
        # Failed (syntax or file not found)
        echo "$script FAILED: $AUTO_TEST_REASON"
        mkdir -p "failed"
        echo "$script FAILED: $AUTO_TEST_REASON" >> "$log_file"
        mv -f "$script" "failed/$script"
        if $check_mode; then
            echo "(Skipping interactive check due to error. Press Enter to continue.)"
            read -r
        fi
        return
    fi

    # Handle results based on mode
    if $check_mode; then
        # Show each scenario interactively
        show_interactive_guide 1 "$AUTO_TEST_RES1"
        run_interactive_test "$script"

        show_interactive_guide 2 "$AUTO_TEST_RES2"
        run_interactive_test "$script"

        show_interactive_guide 3 "$AUTO_TEST_RES3"
        run_interactive_test "$script"

        if ! $AUTO_TEST_NO_COLON_TEST; then
            show_interactive_guide 4 "$AUTO_TEST_RES4"
            run_interactive_test "$script"
        fi

        # Show final grade
        case "$AUTO_TEST_GRADE" in
            Perfect) echo "OVERALL GRADE: PERFECT - $AUTO_TEST_REASON" ;;
            Passed)  echo "OVERALL GRADE: PASSED - $AUTO_TEST_REASON" ;;
            Failed)  echo "OVERALL GRADE: FAILED - $AUTO_TEST_REASON" ;;
        esac

        get_user_override "$AUTO_TEST_GRADE" "$AUTO_TEST_REASON"
        log_and_categorize "$script" "$grade_override" "$comments"
    else
        # Non-interactive: log and move automatically
        if [[ "$AUTO_TEST_GRADE" == "Failed" ]]; then
            mkdir -p "failed"
            echo "$script FAILED: $AUTO_TEST_REASON" >> "$log_file"
            mv -f "$script" "failed/$script"
            echo "$script: FAILED ($AUTO_TEST_REASON)"
        elif [[ "$AUTO_TEST_GRADE" == "Perfect" ]]; then
            mkdir -p "perfect"
            echo "$script PASSED: Perfect." >> "$log_file"
            mv -f "$script" "perfect/$script"
            echo "$script: PASSED (Perfect)"
        else
            mkdir -p "passed"
            echo "$script PASSED: $AUTO_TEST_REASON" >> "$log_file"
            mv -f "$script" "passed/$script"
            echo "$script: PASSED"
        fi
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