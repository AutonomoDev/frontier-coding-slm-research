<?php

namespace Autonomo\SourceCodeGrader;

interface LLMGrader
{
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
    ): array;
}
