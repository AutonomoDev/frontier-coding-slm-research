<?php declare(strict_types=1);

namespace Autonomo\SourceCodeGrader;

use Autonomo\AISpeaker\LLMSpeaker;
use Autonomo\AISpeaker\ChatGPTSpeaker;
use InvalidArgumentException;

class Gemini_SourceCodeGrader implements LLMGrader
{
    private LLMSpeaker $ai;
    private string $gradingPromptTemplate;

    /**
     * @param string              $gradingPromptFilename The path to the file containing the grading prompt template.
     * @param LLMSpeaker|null     $api                   An instance of ChatGPTSpeaker, or null to create a new one.
     */
    public function __construct(string $gradingPromptFilename, ?LLMSpeaker $api = null)
    {
        if (!file_exists($gradingPromptFilename) || !is_readable($gradingPromptFilename)) {
            throw new InvalidArgumentException(
                "Grading instruction file not found or is not readable: $gradingPromptFilename"
            );
        }

        $this->gradingPromptTemplate = file_get_contents($gradingPromptFilename);
        $this->ai = $api ?? new LLMSpeaker('gemini');
    }

    /**
     * Grades one or more source code submissions using ChatGPT.
     *
     * This method can accept a single submission's data or arrays for batch processing multiple submissions.
     * When batch processing, all parameter arrays must have the same number of elements.
     *
     * @param string|string[] $authors The author's name or an array of names.
     * @param string|string[] $times The development time (e.g., "00:15:30") or an array of times.
     * @param string|string[] $testConditions The test condition ("pass" or failure reason) or an array of them.
     * @param string|string[] $codeFilenames The path to the source code file or an array of paths.
     * @return array Returns a single grading result array or an array of result arrays.
     */
    public function grade(
        string|array $authors,
        string|array $times,
        string|array $testConditions,
        string|array $codeFilenames
    ): array {
        // Normalize all inputs to arrays to unify the processing logic
        $wasSingleItem = !is_array($authors);
        $authors = $wasSingleItem ? [$authors] : $authors;
        $times = $wasSingleItem ? [$times] : $times;
        $testConditions = $wasSingleItem ? [$testConditions] : $testConditions;
        $codeFilenames = $wasSingleItem ? [$codeFilenames] : $codeFilenames;

        // Validate that all arrays have the same length for batch processing
        if (count($authors) !== count($times) || count($authors) !== count($testConditions) || count($authors) !== count($codeFilenames)) {
            throw new InvalidArgumentException("When providing arrays, all input arrays must have the same number of elements.");
        }

        $results = [];
        // I am assuming we want a JSON response, as it is structured and easier to parse.
        $this->ai->returnJSON();

        foreach ($authors as $index => $author) {
            $codeFilename = $codeFilenames[$index];

            if (!file_exists($codeFilename) || !is_readable($codeFilename)) {
                $results[] = [
                    'author' => $author,
                    'error' => "Source code file not found or is not readable: $codeFilename"
                ];
                continue; // Skip to the next item in the batch
            }

            $scriptContent = file_get_contents($codeFilename);

            $replacements = [
                '[FAIL LOG]' => $testConditions[$index],
                '[TIMINGS]'  => $times[$index],
                '[SCRIPTS]'  => "$author\n```php\n$scriptContent\n```",
            ];

            // Build the final prompt by replacing the placeholders
            $finalPrompt = str_replace(array_keys($replacements), array_values($replacements), $this->gradingPromptTemplate);

            // Per your instructions, call the ChatGPT API.
            // The provided ChatGPTSpeaker class does not have an 'o3' method.
            // The `prompt()` method is the most suitable general-purpose choice.
            $response = $this->ai->prompt($finalPrompt);

            $results[] = [
                'author' => $author,
                'filename' => $codeFilename,
                'grade_response' => $response->getcontent(),
            ];
        }

        // If a single item was passed in, return only its result, not an array containing one result.
        return $wasSingleItem ? $results[0] : $results;
    }
}
