# [[HUMAN COMMENTED-OUT]]
#Here is the requested code snippet:

# 1. Save the original word break characters.
local _old_wb=${COMP_WORDBREAKS}
# 2. Modify COMP_WORDBREAKS to remove the colon.
COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
# 3. Use the helper to re-parse and correctly set `cur` and `prev`.
#    The `-n :` option tells it to NOT use the colon as a separator.
_get_comp_words_by_ref -n : cur prev
# 4. Restore the original word breaks immediately to avoid side-effects.
COMP_WORDBREAKS=${_old_wb}

