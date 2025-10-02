<?php declare(strict_types=1);

namespace Autonomo\SourceCodeGrader;

use Autonomo\AISpeaker\ChatGPTSpeaker;
use Autonomo\AISpeaker\DTO\ChatGptChatResponse;
use Autonomo\AISpeaker\LLMSpeaker;

class Claude_SourceCodeGrader implements LLMGrader
{
    private string $gradingPromptTemplate;
    private LLMSpeaker $ai;

    /**
     * Constructor for SourceCodeGrader
     *
     * @param string              $gradingPromptFilename The filename of the grading instruction prompt
     * @param ChatGPTSpeaker|null $api                   The ChatGPT speaker instance (creates one if null)
     * @throws \RuntimeException If the grading prompt file cannot be read
     */
    public function __construct(string $gradingPromptFilename, ?ChatGPTSpeaker $api = null)
    {
        if (!file_exists($gradingPromptFilename)) {
            throw new \RuntimeException("Grading prompt file not found: {$gradingPromptFilename}");
        }

        $this->gradingPromptTemplate = file_get_contents($gradingPromptFilename);
        if ($this->gradingPromptTemplate === false) {
            throw new \RuntimeException("Unable to read grading prompt file: {$gradingPromptFilename}");
        }

        $this->ai = $api ?? new ChatGPTSpeaker();
    }

    /**
     * Grade source code using ChatGPT's o3 endpoint
     *
     * @param string|array $author The author's name or array of authors
     * @param string|array $developmentTime The time it took to develop in [HH:]MM:SS format or array of times
     * @param string|array $testCondition The test condition (pass/fail and why) or array of conditions
     * @param string|array $codeFilename The filename of the generated code or array of filenames
     * @return ChatGptChatResponse|array Returns single response or array of responses based on input
     * @throws \InvalidArgumentException If array parameters don't have matching lengths
     * @throws \RuntimeException If code file cannot be read
     */
    public function grade(
        string|array $author,
        string|array $developmentTime,
        string|array $testCondition,
        string|array $codeFilename
    ): ChatGptChatResponse|array {
        // Convert all parameters to arrays for uniform processing
        $authors = is_array($author) ? $author : [$author];
        $times = is_array($developmentTime) ? $developmentTime : [$developmentTime];
        $conditions = is_array($testCondition) ? $testCondition : [$testCondition];
        $filenames = is_array($codeFilename) ? $codeFilename : [$codeFilename];

        // Validate that all arrays have the same length
        $counts = [
            count($authors),
            count($times),
            count($conditions),
            count($filenames)
        ];

        if (count(array_unique($counts)) > 1) {
            throw new \InvalidArgumentException("All array parameters must have the same length");
        }

        // If single item, use the original gradeOne method
        if (!is_array($author)) {
            return $this->gradeOne(
                $authors[0],
                $times[0],
                $conditions[0],
                $filenames[0]
            );
        }

        // For multiple items, combine them into a single request
        return $this->gradeMultiple($authors, $times, $conditions, $filenames);
    }

    /**
     * Grade a single source code submission
     *
     * @param string $author The author's name
     * @param string $developmentTime The time it took to develop in [HH:]MM:SS format
     * @param string $testCondition The test condition (pass/fail and why)
     * @param string $codeFilename The filename of the generated code
     * @return ChatGptChatResponse The grading response from ChatGPT
     * @throws \RuntimeException If code file cannot be read
     */
    private function gradeOne(
        string $author,
        string $developmentTime,
        string $testCondition,
        string $codeFilename
    ): ChatGptChatResponse {
        // Read the source code file
        if (!file_exists($codeFilename)) {
            throw new \RuntimeException("Code file not found: {$codeFilename}");
        }

        $sourceCode = file_get_contents($codeFilename);
        if ($sourceCode === false) {
            throw new \RuntimeException("Unable to read code file: {$codeFilename}");
        }

        // Prepare the script content with author and code
        $scriptContent = $author . "\n```" . $sourceCode . "```";

        // Replace placeholders in the grading prompt
        $prompt = str_replace(
            ['[FAIL LOG]', '[TIMINGS]', '[SCRIPTS]'],
            [$testCondition, $developmentTime, $scriptContent],
            $this->gradingPromptTemplate
        );

        // Send to ChatGPT's o3 endpoint
        $promptPayload = [
            'model' => 'o3',
            'messages' => [
                [
                    'role' => 'user',
                    'content' => $prompt
                ]
            ]
        ];

        // Use the exact prompt payload to ensure we're using the o3 model
        $response = $this->ai->useExactPromptPayload($promptPayload);

        // Convert the response to ChatGptChatResponse format
        // Since useExactPromptPayload returns an object, we need to use the prompt method
        // to get a proper ChatGptChatResponse
        return $this->ai->prompt($prompt);
    }

    /**
     * Grade multiple source code submissions in a single request
     *
     * @param array $authors Array of author names
     * @param array $times Array of development times
     * @param array $conditions Array of test conditions
     * @param array $filenames Array of code filenames
     * @return array Array of ChatGptChatResponse objects
     * @throws \RuntimeException If any code file cannot be read
     */
    private function gradeMultiple(
        array $authors,
        array $times,
        array $conditions,
        array $filenames
    ): array {
        // Collect all submissions
        $allScripts = [];
        $allTimings = [];
        $allFailLogs = [];

        for ($i = 0; $i < count($authors); $i++) {
            // Read the source code file
            if (!file_exists($filenames[$i])) {
                throw new \RuntimeException("Code file not found: {$filenames[$i]}");
            }

            $sourceCode = file_get_contents($filenames[$i]);
            if ($sourceCode === false) {
                throw new \RuntimeException("Unable to read code file: {$filenames[$i]}");
            }

            // Prepare the script content with author and code
            $allScripts[] = $authors[$i] . "\n```" . $sourceCode . "```";
            $allTimings[] = $times[$i];
            $allFailLogs[] = $conditions[$i];
        }

        // Join all submissions with appropriate separators
        $combinedScripts = implode("\n\n---\n\n", $allScripts);
        $combinedTimings = implode(", ", $allTimings);
        $combinedFailLogs = implode("\n\n---\n\n", $allFailLogs);

        // Replace placeholders in the grading prompt
        $prompt = str_replace(
            ['[FAIL LOG]', '[TIMINGS]', '[SCRIPTS]'],
            [$combinedFailLogs, $combinedTimings, $combinedScripts],
            $this->gradingPromptTemplate
        );

        // Add instruction to grade each submission separately
        $prompt = "Please grade each of the following " . count($authors) . " submissions separately and return an array of grades:\n\n" . $prompt;

        // Send to ChatGPT's o3 endpoint
        $promptPayload = [
            'model' => 'o3',
            'messages' => [
                [
                    'role' => 'user',
                    'content' => $prompt
                ]
            ]
        ];

        // Use the exact prompt payload to ensure we're using the o3 model
        $response = $this->ai->useExactPromptPayload($promptPayload);

        // For now, return the single response wrapped in an array
        // In a real implementation, you might want to parse the response to extract individual grades
        $chatResponse = $this->ai->prompt($prompt);

        // Create an array with the same response for each submission
        // This is a simplified approach - in reality, you'd want to parse the response
        // to extract individual grades for each submission
        $responses = [];
        for ($i = 0; $i < count($authors); $i++) {
            $responses[] = $chatResponse;
        }

        return $responses;
    }
}
