<?php

// Validate command line arguments
if ($argc !== 2) {
    echo "Usage: php {$argv[0]} PATH\n";
    exit(1);
}

$basePath = $argv[1];

// Process all version directories
$versionDirs = glob($basePath . '/v*', GLOB_ONLYDIR);
foreach ($versionDirs as $versionDir) {
    processVersionDirectory($versionDir);
}

/**
 * Process all iteration directories within a version directory
 */
function processVersionDirectory($versionDir) {
    $iterationDirs = glob($versionDir . '/*', GLOB_ONLYDIR);
    
    foreach ($iterationDirs as $iterationDir) {
        if (!isNumericDirectory($iterationDir)) {
            continue;
        }
        
        processIterationDirectory($iterationDir);
    }
}

/**
 * Check if directory has a numeric name
 */
function isNumericDirectory($dir) {
    return is_numeric(basename($dir));
}

/**
 * Process a single iteration directory's test results
 */
function processIterationDirectory($iterationDir) {
    $testLogPath = $iterationDir . '/test.log';
    
    if (!file_exists($testLogPath)) {
        return;
    }
    
    $perfectScripts = findPerfectScripts($testLogPath);
    movePerfectScripts($iterationDir, $perfectScripts);
}

/**
 * Parse test.log and find all scripts that passed perfectly
 */
function findPerfectScripts($testLogPath) {
    $lines = file($testLogPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $perfectScripts = [];
    
    foreach ($lines as $line) {
        if (preg_match('/^(.+\.sh) PASSED: Perfect\.$/', $line, $matches)) {
            $perfectScripts[] = $matches[1];
        }
    }
    
    return $perfectScripts;
}

/**
 * Move perfect scripts from passed/ to perfect/ directory
 */
function movePerfectScripts($iterationDir, $perfectScripts) {
    $passedDir = $iterationDir . '/passed';
    $perfectDir = $iterationDir . '/perfect';
    
    ensureDirectoryExists($perfectDir);
    
    foreach ($perfectScripts as $scriptName) {
        moveScript($passedDir, $perfectDir, $scriptName, $iterationDir);
    }
}

/**
 * Create directory if it doesn't exist
 */
function ensureDirectoryExists($dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
}

/**
 * Move a single script file and report the result
 */
function moveScript($fromDir, $toDir, $scriptName, $iterationDir) {
    $sourcePath = $fromDir . '/' . $scriptName;
    $destPath = $toDir . '/' . $scriptName;
    
    if (file_exists($sourcePath)) {
        rename($sourcePath, $destPath);
        echo "Moved $scriptName to perfect/ in $iterationDir\n";
    } else {
        echo "Warning: $scriptName not found in passed/ in $iterationDir\n";
    }
}
