<?php

// Validate command line arguments
if ($argc !== 2) {
    echo "Usage: php {$argv[0]} PATH\n";
    exit(1);
}

$basePath = $argv[1];

// Canonical model mapping (model key => model ID and script suffix)
$CANONICAL_MODELS = [
    'qwen3-coder:30b' => ['id' => 1, 'suffix' => 'qwen3_coder_30b'],
    'gemma3:27b' => ['id' => 2, 'suffix' => 'google_gemma3_27b'],
    'gpt-oss:20b' => ['id' => 3, 'suffix' => 'openai_gpt_oss_20b'],
    'wizardcoder:33b' => ['id' => 4, 'suffix' => 'wizardcoder_33b'],
    'deepseek-coder-v2:16b' => ['id' => 5, 'suffix' => 'deepseek_coder_v2_16b'],
    'deepseek-r1:14b' => ['id' => 6, 'suffix' => 'deepseek_r1_14b'],
    'deepseek-r1:32b' => ['id' => 7, 'suffix' => 'deepseek_r1_32b'],
    'xiaowangge/deepseek-v3-qwen2.5:32b' => ['id' => 8, 'suffix' => 'deepseek_v3_qwen2.5_32b'],
    'gemma3:12b' => ['id' => 9, 'suffix' => 'google_gemma3_12b'],
    'codellama:13b' => ['id' => 10, 'suffix' => 'meta_codellama_13b'],
    'codellama:34b' => ['id' => 11, 'suffix' => 'meta_codellama_34b'],
    'phi4:14b' => ['id' => 12, 'suffix' => 'microsoft_phi4_14b'],
    'codestral:22b' => ['id' => 13, 'suffix' => 'mistral_codestral_22b'],
    'mistral-small:24b' => ['id' => 14, 'suffix' => 'mistral_small_24b'],
    'phind-codellama:34b' => ['id' => 15, 'suffix' => 'phind_codellama_34b'],
    'phi4-reasoning:14b' => ['id' => 16, 'suffix' => 'microsoft_phi4_reasoning_14b'],
    'olympus-coder:13b' => ['id' => 17, 'suffix' => 'aadi19_olympus_coder_13b'],
];

// Process all version directories
$versionDirs = glob($basePath . '/v*', GLOB_ONLYDIR);
foreach ($versionDirs as $versionDir) {
    processVersionDirectory($versionDir, $CANONICAL_MODELS);
}

/**
 * Process a version directory and unify model names
 */
function processVersionDirectory($versionDir, $canonicalModels) {
    $version = extractVersionNumber($versionDir);
    if ($version === null) {
        return;
    }

    $modelsFile = $versionDir . '/models.txt';
    if (!file_exists($modelsFile)) {
        echo "No models.txt found in $versionDir\n";
        return;
    }

    echo "Processing $versionDir (version $version)\n";

    $entries = parseModelsFile($modelsFile);

    // Process each iteration directory
    $iterationDirs = glob($versionDir . '/*', GLOB_ONLYDIR);
    foreach ($iterationDirs as $iterationDir) {
        if (!isNumericDirectory($iterationDir)) {
            continue;
        }

        echo "  Processing iteration: " . basename($iterationDir) . "\n";
        processIterationDirectory($iterationDir, $version, $entries, $canonicalModels);
    }

    // Update models.txt with corrected entries
    $updatedEntries = buildUpdatedEntries($entries, $version, $canonicalModels);
    writeModelsFile($modelsFile, $updatedEntries, $canonicalModels);
}

/**
 * Extract version number from directory name (e.g., "v9" => 9)
 */
function extractVersionNumber($versionDir) {
    $dirName = basename($versionDir);
    if (preg_match('/^v(\d+)$/', $dirName, $matches)) {
        return (int)$matches[1];
    }
    return null;
}

/**
 * Check if directory has a numeric name
 */
function isNumericDirectory($dir) {
    return is_numeric(basename($dir));
}

/**
 * Parse models.txt file into array of entries
 */
function parseModelsFile($modelsFile) {
    $lines = file($modelsFile, FILE_IGNORE_NEW_LINES);
    $entries = [];

    foreach ($lines as $line) {
        $line = trim($line);
        if (empty($line) || strpos($line, '=>') === false) {
            continue;
        }

        $parts = array_map('trim', explode('=>', $line, 2));
        if (count($parts) === 2) {
            $entries[] = [
                'model_key' => $parts[0],
                'old_filename' => $parts[1]
            ];
        }
    }

    return $entries;
}

/**
 * Process files in a single iteration directory
 */
function processIterationDirectory($iterationDir, $version, $entries, $canonicalModels) {
    foreach ($entries as $entry) {
        $modelKey = $entry['model_key'];
        $oldFilename = $entry['old_filename'];

        if (!isset($canonicalModels[$modelKey])) {
            continue;
        }

        $modelInfo = $canonicalModels[$modelKey];
        $newFilename = buildCorrectFilename($version, $modelInfo['id'], $modelInfo['suffix']);

        if ($oldFilename !== $newFilename) {
            renameModelFile($iterationDir, $oldFilename, $newFilename, $modelKey);
        }
    }
}

/**
 * Build the correct filename for a model
 */
function buildCorrectFilename($version, $modelId, $suffix) {
    return "prompt.v{$version}-{$modelId}.{$suffix}.sh";
}

/**
 * Rename a model file using git mv
 */
function renameModelFile($iterationDir, $oldFilename, $newFilename, $modelKey) {
    $oldPath = $iterationDir . '/' . $oldFilename;
    $newPath = $iterationDir . '/' . $newFilename;

    if (!file_exists($oldPath)) {
        // File might not exist in this iteration, skip silently
        return;
    }

    // Use git mv to rename the file
    $oldPathEscaped = escapeshellarg($oldPath);
    $newPathEscaped = escapeshellarg($newPath);
    $command = "git mv $oldPathEscaped $newPathEscaped 2>&1";

    exec($command, $output, $returnCode);

    if ($returnCode === 0) {
        echo "    Renamed: $oldFilename => $newFilename\n";
    } else {
        echo "    Error: Failed to git mv $oldFilename\n";
        if (!empty($output)) {
            echo "      Git output: " . implode("\n      ", $output) . "\n";
        }
    }
}

/**
 * Build updated entries for models.txt
 */
function buildUpdatedEntries($entries, $version, $canonicalModels) {
    $updatedEntries = [];

    foreach ($entries as $entry) {
        $modelKey = $entry['model_key'];

        if (!isset($canonicalModels[$modelKey])) {
            echo "  Warning: Unknown model '$modelKey' - keeping as-is\n";
            $updatedEntries[] = ['model_key' => $modelKey, 'filename' => $entry['old_filename']];
            continue;
        }

        $modelInfo = $canonicalModels[$modelKey];
        $newFilename = buildCorrectFilename($version, $modelInfo['id'], $modelInfo['suffix']);

        $updatedEntries[] = ['model_key' => $modelKey, 'filename' => $newFilename];
    }

    return $updatedEntries;
}

/**
 * Write updated entries back to models.txt, sorted by model ID
 */
function writeModelsFile($modelsFile, $entries, $canonicalModels) {
    // Sort entries by model ID
    usort($entries, function($a, $b) use ($canonicalModels) {
        $idA = isset($canonicalModels[$a['model_key']]) ? $canonicalModels[$a['model_key']]['id'] : 999;
        $idB = isset($canonicalModels[$b['model_key']]) ? $canonicalModels[$b['model_key']]['id'] : 999;
        return $idA - $idB;
    });

    $lines = [];
    foreach ($entries as $entry) {
        $lines[] = $entry['model_key'] . ' => ' . $entry['filename'];
    }

    file_put_contents($modelsFile, implode("\n", $lines) . "\n");
    echo "  Updated models.txt\n\n";
}