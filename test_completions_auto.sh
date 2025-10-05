#!/bin/bash
# test_completions_auto.sh
#
# Automated testing library and script for bash completion files.
#
# Usage as script:
#   test_completions_auto.sh <completion_script>
#
# Usage as library:
#   source test_completions_auto.sh
#   auto_test_init
#   auto_test_run "path/to/completion_script.sh"
#   # Access results via: $AUTO_TEST_GRADE, $AUTO_TEST_REASON, etc.

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
# GET EXPECTED MODELS: Extract model list from ollama.           #
################################################################
get_expected_models() {
    ollama_list_out="$(ollama list 2>/dev/null)"
    if [[ -z "$ollama_list_out" ]]; then
        echo "Warning: 'ollama list' returned no output (command not found or no models)." >&2
    fi

    AUTO_TEST_EXPECTED_MODELS=()
    while IFS= read -r line; do
        # Skip header or empty lines
        [[ -z "$line" ]] && continue
        first_field="${line%%[ $'\t']*}"
        [[ "$first_field" == "NAME" ]] && continue  # skip header
        AUTO_TEST_EXPECTED_MODELS+=("$first_field")
    done <<< "$ollama_list_out"

    # Sort expected models for comparison
    AUTO_TEST_SORTED_EXPECTED=($(printf "%s\n" "${AUTO_TEST_EXPECTED_MODELS[@]}" | sort))
}

################################################################
# FIND MULTI TAG MODEL: Identify a model with multiple tags.     #
################################################################
find_multi_tag_model() {
    declare -gA AUTO_TEST_BASE_TO_TAGS
    for model in "${AUTO_TEST_EXPECTED_MODELS[@]}"; do
        base="${model%%:*}"; tag="${model#*:}"
        AUTO_TEST_BASE_TO_TAGS["$base"]+="$tag "
    done

    AUTO_TEST_TARGET_BASE=""
    for base in "${!AUTO_TEST_BASE_TO_TAGS[@]}"; do
        # Count tags for this base
        tags=(${AUTO_TEST_BASE_TO_TAGS[$base]})
        if (( ${#tags[@]} > 1 )); then
            AUTO_TEST_TARGET_BASE="$base"
            # Prefer 'codellama' if present
            [[ "$base" == "codellama" ]] && break
        fi
    done

    AUTO_TEST_NO_COLON_TEST=false
    if [[ -z "$AUTO_TEST_TARGET_BASE" ]]; then
        AUTO_TEST_NO_COLON_TEST=true  # no multi-tag model found
    fi
}

################################################################
# CHECK SYNTAX: Verify bash syntax of script.                    #
################################################################
check_syntax() {
    local script="$1"
    bash -n "$script" 2>/dev/null
}

################################################################
# RUN TEST SCENARIOS: Execute all completion test cases.         #
################################################################
run_test_scenarios() {
    local script="$1"

    # Initialize results
    AUTO_TEST_RES1=""
    AUTO_TEST_RES2=""
    AUTO_TEST_RES3=""
    AUTO_TEST_RES4=""
    AUTO_TEST_COLON_INCOMPLETE=false

    # Scenario 1: "ollama " -> no suggestions
    local comp_point="${#comp_line}"
    AUTO_TEST_RES1="$(run_completion "$script" "ollama " '(ollama "")' 1 7)"
    AUTO_TEST_RES1="${AUTO_TEST_RES1%$'\n'}"

    # Scenario 2: "ollama run " -> expect all model names:tags
    AUTO_TEST_RES2="$(run_completion "$script" "ollama run " '(ollama run "")' 2 11)"
    AUTO_TEST_RES2="${AUTO_TEST_RES2%$'\n'}"

    # Scenario 3: "ollama run code" -> expect models starting with "code"
    AUTO_TEST_RES3="$(run_completion "$script" "ollama run code" '(ollama run code)' 2 15)"
    AUTO_TEST_RES3="${AUTO_TEST_RES3%$'\n'}"

    # Scenario 4: "ollama run $target_base:" -> expect tags only (if applicable)
    if ! $AUTO_TEST_NO_COLON_TEST; then
        local colon_line="ollama run $AUTO_TEST_TARGET_BASE:"
        local colon_point="${#colon_line}"
        AUTO_TEST_RES4="$(run_completion "$script" "$colon_line" "(ollama run $AUTO_TEST_TARGET_BASE:)" 2 "$colon_point")"
        AUTO_TEST_RES4="${AUTO_TEST_RES4%$'\n'}"
        # Check if suggestions after colon still contain colon (meaning tags not isolated)
        if [[ -n "$AUTO_TEST_RES4" && "$AUTO_TEST_RES4" == *":"* ]]; then
            AUTO_TEST_COLON_INCOMPLETE=true
        fi
    fi
}

################################################################
# EVALUATE RESULTS: Grade test results and determine reason.     #
################################################################
evaluate_results() {
    local fail_reasons=()

    # Scenario 1: should yield nothing
    [[ -n "$AUTO_TEST_RES1" ]] && fail_reasons+=("Unexpected suggestions after 'ollama'")

    # Scenario 2: must list all model names:tags exactly
    if [[ -z "$AUTO_TEST_RES2" ]]; then
        fail_reasons+=("No suggestions after 'ollama run'")
    else
        local res2_set=$(echo "$AUTO_TEST_RES2" | tr ' ' '\n' | sort -u)
        local exp_set=$(printf "%s\n" "${AUTO_TEST_EXPECTED_MODELS[@]}" | sort -u)
        [[ "$res2_set" != "$exp_set" ]] && fail_reasons+=("Incorrect suggestions for 'ollama run' (did not match model list)")
    fi

    # Scenario 3: prefix filtering
    AUTO_TEST_EXPECTED_PREFIX=()
    for m in "${AUTO_TEST_EXPECTED_MODELS[@]}"; do
        [[ "$m" == code* ]] && AUTO_TEST_EXPECTED_PREFIX+=("$m")
    done
    if [[ -z "$AUTO_TEST_RES3" ]]; then
        fail_reasons+=("No suggestions for prefix 'code'")
    else
        local res3_set=$(echo "$AUTO_TEST_RES3" | tr ' ' '\n' | sort -u)
        local prefix_set=$(printf "%s\n" "${AUTO_TEST_EXPECTED_PREFIX[@]}" | sort -u)
        # If environment has no model starting with "code" but we got results, or mismatch in filtering
        if [[ -z "$prefix_set" ]]; then
            [[ -n "$res3_set" ]] && fail_reasons+=("Unexpected suggestions for prefix 'code'")
        elif [[ "$res3_set" != "$prefix_set" ]]; then
            fail_reasons+=("Incorrect suggestions for prefix 'code'")
        fi
    fi

    # Scenario 4: tags after colon (only fail if completely breaks)
    if ! $AUTO_TEST_NO_COLON_TEST; then
        if [[ -z "$AUTO_TEST_RES4" ]]; then
            fail_reasons+=("No suggestions after '$AUTO_TEST_TARGET_BASE:'")
        fi
    fi

    # Assign grade
    if ((${#fail_reasons[@]} > 0)); then
        AUTO_TEST_GRADE="Failed"
        # Combine multiple reasons into one string
        AUTO_TEST_REASON="${fail_reasons[0]}"
        if ((${#fail_reasons[@]} > 1)); then
            for ((i=1; i<${#fail_reasons[@]}; i++)); do
                AUTO_TEST_REASON="$AUTO_TEST_REASON; ${fail_reasons[$i]}"
            done
        fi
    else
        # No fail conditions -> Passed or Perfect
        if ! $AUTO_TEST_NO_COLON_TEST && [[ -n "$AUTO_TEST_RES4" && $AUTO_TEST_COLON_INCOMPLETE == false ]]; then
            AUTO_TEST_GRADE="Perfect"
            AUTO_TEST_REASON="Handles ':' tags correctly (all criteria passed)"
        else
            AUTO_TEST_GRADE="Passed"
            # Reason for pass: either no multi-tag scenario or it stopped at colon
            if ! $AUTO_TEST_NO_COLON_TEST; then
                AUTO_TEST_REASON="When multiple models share a name, completion stops at ':' (tags not listed)"
            else
                AUTO_TEST_REASON="All basic completion tests passed"
            fi
        fi
    fi
}

################################################################
# AUTO TEST INIT: Initialize testing environment.                #
################################################################
auto_test_init() {
    get_expected_models
    find_multi_tag_model
}

################################################################
# AUTO TEST RUN: Run automated tests on a completion script.     #
################################################################
auto_test_run() {
    local script="$1"

    # Reset results
    AUTO_TEST_GRADE=""
    AUTO_TEST_REASON=""

    # Check if script exists
    if [[ ! -f "$script" ]]; then
        AUTO_TEST_GRADE="Failed"
        AUTO_TEST_REASON="Script file not found: $script"
        return 1
    fi

    # Syntax check
    if ! check_syntax "$script"; then
        AUTO_TEST_GRADE="Failed"
        AUTO_TEST_REASON="Bash syntax error"
        return 1
    fi

    # Run test scenarios
    run_test_scenarios "$script"

    # Evaluate results
    evaluate_results

    return 0
}

################################################################
# MAIN: Entry point when run as standalone script.              #
################################################################
main() {
    if [[ -z "$1" ]]; then
        echo "Usage: $0 <completion_script>" >&2
        echo "" >&2
        echo "This script tests bash completion files for ollama." >&2
        echo "It can also be sourced as a library." >&2
        exit 1
    fi

    local script="$1"

    echo "Initializing automated tests..."
    auto_test_init

    echo "Testing: $script"
    if auto_test_run "$script"; then
        echo ""
        echo "Results:"
        echo "  Grade:  $AUTO_TEST_GRADE"
        echo "  Reason: $AUTO_TEST_REASON"
        echo ""
        echo "Scenario Results:"
        echo "  1. 'ollama '          → '$AUTO_TEST_RES1'"
        echo "  2. 'ollama run '      → '${AUTO_TEST_RES2:0:50}...'"
        echo "  3. 'ollama run code'  → '$AUTO_TEST_RES3'"
        if ! $AUTO_TEST_NO_COLON_TEST; then
            echo "  4. 'ollama run $AUTO_TEST_TARGET_BASE:' → '$AUTO_TEST_RES4'"
        else
            echo "  4. (skipped - no multi-tag models)"
        fi

        if [[ "$AUTO_TEST_GRADE" == "Failed" ]]; then
            exit 1
        else
            exit 0
        fi
    else
        echo "FAILED: $AUTO_TEST_REASON" >&2
        exit 1
    fi
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
