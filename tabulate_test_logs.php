<?php

// Read all input lines from stdin
$lines = [];
while (($line = fgets(STDIN)) !== false) {
    $trimmed = trim($line);
    if (strpos($trimmed, 'FAILED:') === 0 || strpos($trimmed, 'PASSED:') === 0) {
        $lines[] = $trimmed;
    }
}

// Group and count unique lines
$counts = [];
foreach ($lines as $line) {
    if (!isset($counts[$line])) {
        $counts[$line] = 0;
    }
    $counts[$line]++;
}

// Separate into FAILED, PASSED (non-Perfect), and PERFECT
$failed = [];
$passed = [];
$perfect = [];
foreach ($counts as $line => $count) {
    if (strpos($line, 'FAILED:') === 0) {
        $failed[$line] = $count;
    } elseif (strpos($line, 'PASSED:') === 0) {
        // Handle variations of "Perfect" (with or without period/period placement)
        if (strpos($line, 'Perfect') !== false) {
            $perfect[$line] = $count;
        } else {
            $passed[$line] = $count;
        }
    }
}

// Prepare lists for sorting (filter >=5 at this stage for efficiency)
$failed_list = [];
foreach ($failed as $line => $count) {
    if ($count >= 5) {
        $failed_list[] = [$line, $count];
    }
}

$passed_list = [];
foreach ($passed as $line => $count) {
    if ($count >= 5) {
        $passed_list[] = [$line, $count];
    }
}

$perfect_list = [];
foreach ($perfect as $line => $count) {
    if ($count >= 5) {
        $perfect_list[] = [$line, $count];
    }
}

// Sort each list: count descending, then line alphabetically
$sort_cmp = function($a, $b) {
    if ($a[1] != $b[1]) {
        return $b[1] - $a[1]; // Descending count
    }
    return strcmp($a[0], $b[0]); // Alphabetical if tie
};

usort($failed_list, $sort_cmp);
usort($passed_list, $sort_cmp);
usort($perfect_list, $sort_cmp);

// Output FAILED first (>=5)
foreach ($failed_list as $item) {
    echo $item[1] . ' ' . $item[0] . "\n";
}

// Then PASSED (non-Perfect, >=5)
foreach ($passed_list as $item) {
    echo $item[1] . ' ' . $item[0] . "\n";
}

// Then PERFECT last (>=5)
foreach ($perfect_list as $item) {
    echo $item[1] . ' ' . $item[0] . "\n";
}
