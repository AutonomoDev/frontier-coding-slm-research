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

// Create a reverse mapping for efficient lookup: suffix => model_key
$suffixToModelKey = [];
foreach ($CANONICAL_MODELS as $modelKey => $info) {
    $suffixToModelKey[$info['suffix']] = $modelKey;
}

// Process all version directories
$versionDirs = glob($basePath . '/v*', GLOB_ONLYDIR);
foreach ($versionDirs as $versionDir) {
    processVersionDirectory($versionDir, $CANONICAL_MODELS, $suffixToModelKey);
}

/**
 * Process a version directory and unify model names
 */
function processVersionDirectory($versionDir, $canonicalModels, $suffixToModelKey) {
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

    // Store the original entries from models.txt for later updating models.txt
    $initialModelsFileEntries = parseModelsFile($modelsFile);

    // Process each numeric iteration directory (e.g., 'v4/1', 'v4/2')
    $iterationNumberDirs = glob($versionDir . '/*', GLOB_ONLYDIR);
    foreach ($iterationNumberDirs as $iterationNumberDir) {
        if (!is_numeric(basename($iterationNumberDir))) {
            continue; // Skip non-numeric directories like 'models.txt' or unexpected ones
        }

        echo "  Processing iteration: " . basename($iterationNumberDir) . "\n";

        // Now, within each numeric iteration directory, find 'failed' and 'passed' subdirectories
        $statusDirs = glob($iterationNumberDir . '/*', GLOB_ONLYDIR);
        foreach ($statusDirs as $statusDir) {
            echo "    Processing status directory: " . basename($statusDir) . "\n";
            processFilesInStatusDirectory($statusDir, $version, $canonicalModels, $suffixToModelKey);
        }
    }

    // Update models.txt with corrected entries based on the canonical format
    $updatedEntries = buildUpdatedEntries($initialModelsFileEntries, $version, $canonicalModels);
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
 * Check if directory has a numeric name - (no longer directly used by main loop)
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
                'old_filename' => $parts[1] // Store for models.txt update, not for file lookup
            ];
        }
    }

    return $entries;
}

/**
 * Process files in a single 'failed' or 'passed' directory
 */
function processFilesInStatusDirectory($statusDir, $version, $canonicalModels, $suffixToModelKey) {
    // Get all shell script files directly in this status directory
    $currentFiles = glob($statusDir . '/*.sh');

    foreach ($currentFiles as $oldFullPath) {
        $oldFilename = basename($oldFullPath);

        // Robustly extract the model suffix from the actual filename on disk.
        // This regex handles both '(X) prompt.vN-SUFFIX.sh' and 'prompt.vN-SUFFIX.sh' formats.
        if (!preg_match('/^(?:\(\d+\)\s*)?prompt\.v\d+-([\w\d_.-]+)\.sh$/', $oldFilename, $matches)) {
            echo "      Warning: Could not parse model suffix from filename: $oldFilename (in $statusDir)\n";
            continue;
        }
        $extractedSuffix = $matches[1]; // e.g., 'deepseek_coder_v2_16b'

        // Use the reverse map to find the canonical model key
        if (!isset($suffixToModelKey[$extractedSuffix])) {
            echo "      Warning: Unknown model suffix '$extractedSuffix' found in file '$oldFilename' (in $statusDir) - skipping.\n";
            continue;
        }
        $modelKey = $suffixToModelKey[$extractedSuffix];
        $modelInfo = $canonicalModels[$modelKey];

        // Build the correct new filename based on canonical ID and suffix
        $newFilename = buildCorrectFilename($version, $modelInfo['id'], $modelInfo['suffix']);

        // Only rename if the current filename is different from the desired new filename
        if ($oldFilename !== $newFilename) {
            renameModelFile($statusDir, $oldFilename, $newFilename, $modelKey);
        }
    }
}

/**
 * Build the correct filename for a model
 */
function buildCorrectFilename($version, $modelId, $suffix) {
    // Target format: prompt.v{version}-{modelId}.{suffix}.sh
    return "prompt.v{$version}-{$modelId}.{$suffix}.sh";
}

/**
 * Rename a model file using git mv
 */
function renameModelFile($directory, $oldFilename, $newFilename, $modelKey) {
    $oldPath = $directory . '/' . $oldFilename;
    $newPath = $directory . '/' . $newFilename;

    // file_exists check is now implicit through globbing actual files
    // But if something unexpected happens between glob and rename, this helps.
    if (!file_exists($oldPath)) {
        echo "      Error: File to rename not found: $oldPath (for $modelKey)\n";
        return;
    }

    // Use git mv to rename the file
    $oldPathEscaped = escapeshellarg($oldPath);
    $newPathEscaped = escapeshellarg($newPath);
    $command = "git mv $oldPathEscaped $newPathEscaped 2>&1";

    exec($command, $output, $returnCode);

    if ($returnCode === 0) {
        echo "      Renamed: $oldFilename => $newFilename\n";
    } else {
        echo "      Error: Failed to git mv $oldFilename\n";
        if (!empty($output)) {
            echo "        Git output: " . implode("\n        ", $output) . "\n";
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
            echo "  Warning: Unknown model '$modelKey' in models.txt - keeping filename as-is in output.\n";
            $updatedEntries[] = ['model_key' => $modelKey, 'filename' => $entry['old_filename']];
            continue;
        }

        $modelInfo = $canonicalModels[$modelKey];
        // Ensure models.txt entries reflect the correct, canonical filename format
        $newFilename = buildCorrectFilename($version, $modelInfo['id'], $modelInfo['suffix']);

        $updatedEntries[] = ['model_key' => $modelKey, 'filename' => $newFilename];
    }

    return $updatedEntries;
}

/**
 * Write updated entries back to models.txt, sorted by model ID
 */
function writeModelsFile($modelsFile, $entries, $canonicalModels) {
    // Sort entries by model ID for consistent models.txt order
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