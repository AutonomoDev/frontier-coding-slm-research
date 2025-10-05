#!/bin/bash
# test_completions.sh
#
# Usage: test_completions.sh [--check] <path>
# <path> can be a directory (containing prompt*.sh files) or a single file.
# --check (optional) enables interactive checking after each auto-test.

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
# RUN COMPLETION: Execute completion in configured subshell.     #
################################################################
run_completion() {
    local script="$1"
    local comp_line="$2"
    local comp_words="$3"
    local comp_cword="$4"
    local comp_point="$5"

    bash -c "
        # Load bash-completion functions
        if [[ -f /usr/share/bash-completion/bash_completion ]]; then
            source /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
            source /etc/bash_completion
        fi

        # Source the completion script
        source '$script' 2>/dev/null || exit 1

        # Set completion variables
        COMP_LINE='$comp_line'
        COMP_WORDS=$comp_words
        COMP_CWORD=$comp_cword
        COMP_POINT=$comp_point

        # Find and execute the completion function
        comp_func=\$(complete -p ollama 2>/dev/null | sed -E 's/.*-F ([^ ]+) .*/\1/')
        if [[ -n \"\$comp_func\" ]]; then
            \$comp_func 2>/dev/null
            printf '%s' \"\${COMPREPLY[*]}\"
        fi
    "
}

################################################################
# PREPARE LOG: Initialize the test log file.                     #
################################################################
prepare_log() {
    log_file="test.log"
    touch "$log_file" 2>/dev/null || { echo "Error: Cannot write to $log_file in $(pwd)." >&2; exit 1; }
    echo "=== Test run on $(date) ===" >> "$log_file"
}

################################################################
# GET EXPECTED MODELS: Extract model list from ollama.           #
################################################################
get_expected_models() {
    ollama_list_out="$(ollama list 2>/dev/null)"
    if [[ -z "$ollama_list_out" ]]; then
        echo "Warning: 'ollama list' returned no output (command not found or no models)." >&2
    fi

    expected_models=()
    while IFS= read -r line; do
        # Skip header or empty lines
        [[ -z "$line" ]] && continue
        first_field="${line%%[ $'\t']*}"
        [[ "$first_field" == "NAME" ]] && continue  # skip header
        expected_models+=("$first_field")
    done <<< "$ollama_list_out"

    # Sort expected models for comparison
    sorted_expected=($(printf "%s\n" "${expected_models[@]}" | sort))
}

################################################################
# FIND MULTI TAG MODEL: Identify a model with multiple tags.     #
################################################################
find_multi_tag_model() {
    declare -gA base_to_tags
    for model in "${expected_models[@]}"; do
        base="${model%%:*}"; tag="${model#*:}"
        base_to_tags["$base"]+="$tag "
    done

    target_base=""
    for base in "${!base_to_tags[@]}"; do
        # Count tags for this base
        tags=(${base_to_tags[$base]})
        if (( ${#tags[@]} > 1 )); then
            target_base="$base"
            # Prefer 'codellama' if present
            [[ "$base" == "codellama" ]] && break
        fi
    done

    no_colon_test=false
    if [[ -z "$target_base" ]]; then
        no_colon_test=true  # no multi-tag model found
    fi
}

################################################################
# CHECK SYNTAX: Verify bash syntax of script.                    #
################################################################
check_syntax() {
    local script="$1"
    bash -n "$script" 2>/dev/null
}

##################################################################
# SHOW INTERACTIVE GUIDE: Display manual testing instructions.   #
##################################################################
show_interactive_guide() {
    local scenario="$1"
    local result="$2"
    local expected="$3"

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
            printf "       %s\n" "${expected_models[@]}" | head -5
            if (( ${#expected_models[@]} > 5 )); then
                echo "       ... and $((${#expected_models[@]} - 5)) more"
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
            local expected_prefix=()
            for m in "${expected_models[@]}"; do
                [[ "$m" == code* ]] && expected_prefix+=("$m")
            done
            if (( ${#expected_prefix[@]} > 0 )); then
                printf "       %s\n" "${expected_prefix[@]}"
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
            if ! $no_colon_test; then
                echo "  4. Type: ollama run $target_base:[TAB][TAB]"
                echo "     Expected: Only tags (without '$target_base:' prefix):"
                for tag in ${base_to_tags[$target_base]}; do
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
# TEST AND CHECK SCENARIO: Run individual test with optional check #
################################################################
test_and_check_scenario() {
    local script="$1"
    local scenario="$2"
    local comp_line="$3"
    local comp_words="$4"
    local comp_cword="$5"
    local result=""

    # Run the test
    local comp_point="${#comp_line}"
    result="$(run_completion "$script" "$comp_line" "$comp_words" "$comp_cword" "$comp_point")"
    result="${result%$'\n'}"

    # Store result in appropriate variable
    case "$scenario" in
        1) res1="$result" ;;
        2) res2="$result" ;;
        3) res3="$result" ;;
        4) res4="$result" ;;
    esac

    # If in check mode, show guide and run interactive test for this scenario
    if $check_mode; then
        show_interactive_guide "$scenario" "$result"
        run_interactive_test "$script"
    fi

    return 0
}

################################################################
# RUN TEST SCENARIOS: Execute all completion test cases.         #
################################################################
run_test_scenarios() {
    local script="$1"

    # Initialize results
    res1=""
    res2=""
    res3=""
    res4=""
    colon_incomplete=false

    # Scenario 1: "ollama " -> no suggestions
    test_and_check_scenario "$script" 1 "ollama " '(ollama "")' 1

    # Scenario 2: "ollama run " -> expect all model names:tags
    test_and_check_scenario "$script" 2 "ollama run " '(ollama run "")' 2

    # Scenario 3: "ollama run code" -> expect models starting with "code"
    test_and_check_scenario "$script" 3 "ollama run code" '(ollama run code)' 2

    # Scenario 4: "ollama run $target_base:" -> expect tags only (if applicable)
    if ! $no_colon_test; then
        test_and_check_scenario "$script" 4 "ollama run $target_base:" "(ollama run $target_base:)" 2
        # Check if suggestions after colon still contain colon (meaning tags not isolated)
        if [[ -n "$res4" && "$res4" == *":"* ]]; then
            colon_incomplete=true
        fi
    fi
}

################################################################
# EVALUATE RESULTS: Grade test results and determine reason.     #
################################################################
evaluate_results() {
    # Declare globals that will be set by this function and used by others
    declare -g grade
    declare -g reason
    declare -ga expected_prefix # -g for global, -a for array

    local fail_reasons=()

    # Scenario 1: should yield nothing
    [[ -n "$res1" ]] && fail_reasons+=("Unexpected suggestions after 'ollama'")

    # Scenario 2: must list all model names:tags exactly
    if [[ -z "$res2" ]]; then
        fail_reasons+=("No suggestions after 'ollama run'")
    else
        local res2_set=$(echo "$res2" | tr ' ' '\n' | sort -u)
        local exp_set=$(printf "%s\n" "${expected_models[@]}" | sort -u)
        [[ "$res2_set" != "$exp_set" ]] && fail_reasons+=("Incorrect suggestions for 'ollama run' (did not match model list)")
    fi

    # Scenario 3: prefix filtering
    expected_prefix=()
    for m in "${expected_models[@]}"; do
        [[ "$m" == code* ]] && expected_prefix+=("$m")
    done
    if [[ -z "$res3" ]]; then
        fail_reasons+=("No suggestions for prefix 'code'")
    else
        local res3_set=$(echo "$res3" | tr ' ' '\n' | sort -u)
        local prefix_set=$(printf "%s\n" "${expected_prefix[@]}" | sort -u)
        # If environment has no model starting with "code" but we got results, or mismatch in filtering
        if [[ -z "$prefix_set" ]]; then
            [[ -n "$res3_set" ]] && fail_reasons+=("Unexpected suggestions for prefix 'code'")
        elif [[ "$res3_set" != "$prefix_set" ]]; then
            fail_reasons+=("Incorrect suggestions for prefix 'code'")
        fi
    fi

    # Scenario 4: tags after colon (only fail if completely breaks)
    if ! $no_colon_test; then
        if [[ -z "$res4" ]]; then
            fail_reasons+=("No suggestions after '$target_base:'")
        fi
    fi

    # Assign grade
    if ((${#fail_reasons[@]} > 0)); then
        grade="Failed"
        # Combine multiple reasons into one string
        reason="${fail_reasons[0]}"
        if ((${#fail_reasons[@]} > 1)); then
            for ((i=1; i<${#fail_reasons[@]}; i++)); do
                reason="$reason; ${fail_reasons[$i]}"
            done
        fi
    else
        # No fail conditions -> Passed or Perfect
        if ! $no_colon_test && [[ -n "$res4" && $colon_incomplete == false ]]; then
            grade="Perfect"
            reason="Handles ':' tags correctly (all criteria passed)"
        else
            grade="Passed"
            # Reason for pass: either no multi-tag scenario or it stopped at colon
            if ! $no_colon_test; then
                reason="When multiple models share a name, completion stops at ':' (tags not listed)"
            else
                reason="All basic completion tests passed"
            fi
        fi
    fi
}

################################################################
# GET USER OVERRIDE: Allow manual grade adjustment.              #
################################################################
get_user_override() {
    # Declare globals that will be set by this function and used by others
    declare -g grade_override
    declare -g comments

    echo
    read -p "Auto-graded as $grade. Press Enter to accept, or type new grade [P/p/F]: " _user_grade_input
    _user_grade_input="${_user_grade_input,,}"  # to lowercase
    grade_override="$grade" # Initial value from previous auto-grade
    comments="$reason"     # Initial value from previous auto-grade reason
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

    # 1. Syntax check
    if ! check_syntax "$script"; then
        grade="Failed"
        reason="Bash syntax error"
        echo "$script FAILED: $reason"
        mkdir -p "failed"
        echo "$script FAILED: $reason" >> "$log_file"
        mv -f "$script" "failed/$script"
        if $check_mode; then
            echo "(Skipping interactive check due to syntax error. Press Enter to continue.)"
            read -r
        fi
        return
    fi

    # 2. Run test scenarios (with individual checking if in check mode)
    run_test_scenarios "$script"

    # 3. Evaluate results
    evaluate_results

    # 4. Handle final grading
    if $check_mode; then
        # Show final grade
        case "$grade" in
            Perfect) echo "OVERALL GRADE: PERFECT - $reason" ;;
            Passed)  echo "OVERALL GRADE: PASSED - $reason" ;;
            Failed)  echo "OVERALL GRADE: FAILED - $reason" ;;
        esac

        get_user_override
        log_and_categorize "$script" "$grade_override" "$comments"
    else
        # Non-interactive: log and move automatically
        if [[ "$grade" == "Failed" ]]; then
            mkdir -p "failed"
            echo "$script FAILED: $reason" >> "$log_file"
            mv -f "$script" "failed/$script"
            echo "$script: FAILED ($reason)"
        elif [[ "$grade" == "Perfect" ]]; then
            mkdir -p "perfect"
            echo "$script PASSED: Perfect." >> "$log_file"
            mv -f "$script" "perfect/$script"
            echo "$script: PASSED (Perfect)"
        else
            mkdir -p "passed"
            echo "$script PASSED: $reason" >> "$log_file"
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
    get_expected_models
    find_multi_tag_model

    # Loop through each completion script
    for script in "${scripts_to_test[@]}"; do
        process_script "$script"
    done

    echo "✔️ All done!"
}

# Run main function
main "$@"