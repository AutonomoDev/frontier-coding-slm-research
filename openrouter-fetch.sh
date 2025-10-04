#!/usr/bin/env bash
set -euo pipefail

# Fetches streaming data from OpenRouter API with optional custom system prompt
# Usage: ./openrouter-fetch.sh <model> <user_prompt> [include_reasoning] [system_prompt] [--show-prompt]
#
# Special flags:
#   --show-prompt : Display the full prompt and copy to clipboard, then exit without making API call
#                   Can be passed anywhere in arguments or in parent process

API_URL="https://openrouter.ai/api/v1/chat/completions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source clipboard utilities
if [[ -f "${SCRIPT_DIR}/clipboard.sh" ]]; then
    source "${SCRIPT_DIR}/clipboard.sh"
else
    echo "Warning: clipboard.sh not found. Clipboard functionality will be disabled." >&2
    # Provide stub functions if clipboard.sh is missing
    copy_to_clipboard() { return 1; }
    is_clipboard_available() { return 1; }
fi

# --- Check for --show-prompt flag ---

check_show_prompt_flag() {
    # Check current script arguments
    for arg in "$@"; do
        if [[ "$arg" == "--show-prompt" ]]; then
            return 0
        fi
    done
    
    # Check parent process arguments (if available)
    local parent_pid=$PPID
    if [[ -n "$parent_pid" ]]; then
        # Try Linux /proc method
        if [[ -f "/proc/$parent_pid/cmdline" ]]; then
            if grep -qz -- "--show-prompt" "/proc/$parent_pid/cmdline" 2>/dev/null; then
                return 0
            fi
        fi
        
        # Try ps method (works on macOS and Linux)
        if command -v ps >/dev/null 2>&1; then
            local parent_cmd
            parent_cmd=$(ps -o args= -p "$parent_pid" 2>/dev/null || echo "")
            if [[ "$parent_cmd" == *"--show-prompt"* ]]; then
                return 0
            fi
        fi
    fi
    
    return 1
}

SHOW_PROMPT_ONLY=false
if check_show_prompt_flag "$@"; then
    SHOW_PROMPT_ONLY=true
fi

# --- Parse arguments (filter out --show-prompt) ---

args=()
for arg in "$@"; do
    if [[ "$arg" != "--show-prompt" ]]; then
        args+=("$arg")
    fi
done

if [[ ${#args[@]} -lt 2 ]]; then
    echo "Usage: $0 <model> <user_prompt> [include_reasoning:true|false] [system_prompt] [--show-prompt]" >&2
    echo "" >&2
    echo "Special flags:" >&2
    echo "  --show-prompt : Display the full prompt, copy to clipboard, and exit without making API call" >&2
    exit 1
fi

MODEL="${args[0]}"
USER_PROMPT="${args[1]}"
INCLUDE_REASONING="${args[2]:-true}"
SYSTEM_PROMPT="${args[3]:-You are a helpful assistant. Respond in plain text.}"

# --- Show prompt and exit if requested ---

if [[ "$SHOW_PROMPT_ONLY" == true ]]; then
    # Build the complete prompt text for clipboard
    prompt_text="Model: $MODEL
Include Reasoning: $INCLUDE_REASONING

────────────────────────────────────────────────────────────────
SYSTEM PROMPT:
────────────────────────────────────────────────────────────────
$SYSTEM_PROMPT

────────────────────────────────────────────────────────────────
USER PROMPT:
────────────────────────────────────────────────────────────────
$USER_PROMPT"

    # Display the prompt
    echo "════════════════════════════════════════════════════════════════"
    echo "PROMPT PREVIEW (not executing API call)"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "$prompt_text"
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    
    # Try to copy to clipboard
    if copy_to_clipboard "$prompt_text"; then
        echo "✅ Full prompt is now in your clipboard!"
    else
        echo "ℹ️  (Clipboard copy not available - this is normal on servers/SSH)"
    fi
    
    exit 0
fi

# --- Normal execution ---

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
    echo "Error: OPENROUTER_API_KEY is not set." >&2
    exit 1
fi

if ! command -v curl >/dev/null || ! command -v jq >/dev/null; then
    echo "Error: This script requires curl and jq." >&2
    exit 1
fi

json_payload=$(
    jq -n \
        --arg model "$MODEL" \
        --arg system_prompt "$SYSTEM_PROMPT" \
        --arg user_prompt "$USER_PROMPT" \
        --argjson include_reasoning "$INCLUDE_REASONING" \
        '{
            model: $model,
            stream: true,
            include_reasoning: $include_reasoning,
            messages: [
                {role: "system", content: $system_prompt},
                {role: "user", content: $user_prompt}
            ]
        }'
)

# Stream the SSE response to stdout
curl -sS -N -X POST "$API_URL" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Accept: text/event-stream" \
    -H "HTTP-Referer: https://github.com/your-repo" \
    -H "X-Title: OpenRouter Stream" \
    -d "$json_payload"
