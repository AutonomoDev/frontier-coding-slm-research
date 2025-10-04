#!/usr/bin/env bash
set -euo pipefail

# Parses SSE stream from stdin and displays reasoning + final output
# Optionally writes final output to a file
# Usage: ./openrouter-fetch.sh <model> <prompt> | ./openrouter-parse.sh [output_file]

OUTPUT_FILE="${1:-}"

line_buffer=""
printed_reason_header=0

while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "${line:0:6}" != "data: " ]] && continue
    
    data="${line#data: }"

    if [[ "$data" == "[DONE]" ]]; then
        break
    fi

    # Check for API errors
    err=$(jq -r 'try .error.message // empty' <<<"$data" 2>/dev/null || echo "")
    if [[ -n "$err" && "$err" != "null" ]]; then
        echo >&2
        echo "Error from API: $err" >&2
        exit 1
    fi

    # Handle reasoning tokens
    rchunk=$(jq -r 'try .choices[0].delta.reasoning // empty' <<<"$data" 2>/dev/null || echo "")
    if [[ -n "$rchunk" && "$rchunk" != "null" ]]; then
        if [[ $printed_reason_header -eq 0 ]]; then
            echo "Thinking..."
            printed_reason_header=1
        fi
        printf "%s" "$rchunk"
        continue
    fi

    # Handle final content tokens
    cchunk=$(jq -r 'try .choices[0].delta.content // empty' <<<"$data" 2>/dev/null || echo "")
    if [[ -n "$cchunk" && "$cchunk" != "null" ]]; then
        # Append the new chunk to our buffer
        line_buffer+="$cchunk"

        # Process any COMPLETE lines now in the buffer
        while [[ "$line_buffer" == *$'\n'* ]]; do
            # Extract the full line up to the first newline
            line_to_process="${line_buffer%%$'\n'*}"

            # If the line is NOT a code fence, print it. Otherwise, it's discarded.
            if ! [[ "$line_to_process" =~ ^[[:space:]]*\`\`\` ]]; then
                printf "%s\n" "$line_to_process"
                if [[ -n "$OUTPUT_FILE" ]]; then
                    printf "%s\n" "$line_to_process" >> "$OUTPUT_FILE"
                fi
            fi
            
            # Remove the processed line (and its newline) from the buffer
            line_buffer="${line_buffer#*$'\n'}"
        done

        # After processing full lines, what remains in the buffer is a partial line.
        # We can stream this partial line ONLY IF we know it's not the start of a code fence.
        if [[ -n "$line_buffer" ]] && ! [[ "$line_buffer" =~ ^[[:space:]]*\`\`\` ]]; then
            printf "%s" "$line_buffer"
            if [[ -n "$OUTPUT_FILE" ]]; then
                printf "%s" "$line_buffer" >> "$OUTPUT_FILE"
            fi
            # Since we printed it, clear the buffer. We are now streaming live.
            line_buffer=""
        fi
        continue
    fi
done

# After the loop, a final partial line might be left in the buffer.
# This happens if the stream ends without a newline.
if [[ -n "$line_buffer" ]] && ! [[ "$line_buffer" =~ ^[[:space:]]*\`\`\` ]]; then
    printf "%s" "$line_buffer"
    if [[ -n "$OUTPUT_FILE" ]]; then
        printf "%s" "$line_buffer" >> "$OUTPUT_FILE"
    fi
fi
