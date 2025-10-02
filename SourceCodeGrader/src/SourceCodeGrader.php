<?php declare(strict_types=1);

namespace Autonomo\SourceCodeGrader;

use Autonomo\AISpeaker\ChatGPTSpeaker;
use Autonomo\AISpeaker\DTO\ChatGptChatResponse;

class SourceCodeGrader implements LLMGrader
{
    private LLMGrader $grader;

    /**
     * Constructor for SourceCodeGrader
     *
     * @param string              $gradingPromptFilename The filename of the grading instruction prompt
     * @param ChatGPTSpeaker|null $api                   The ChatGPT speaker instance (creates one if null)
     * @throws \RuntimeException If the grading prompt file cannot be read
     */
    public function __construct(string $gradingPromptFilename, ?ChatGPTSpeaker $api = null, ?LLMGrader $grader = null)
    {
        if ($grader === null) {
            $grader = new Claude_SourceCodeGrader($gradingPromptFilename, $api);
        }

        $this->grader = $grader;
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
    ): ChatGptChatResponse|array
    {
        return $this->grader->grade($author, $developmentTime, $testCondition, $codeFilename);
    }
}
