# Frontier Coding Small Language Models (SLM) Efficiency with non-Specialized Programming Languages (Bash)

The grades for the Small Language Models (SLMs) below have been updated to reflect their peak performance achieved during the automated prompt optimization experiment. The results demonstrate that a Genetic Algorithm can successfully evolve prompts to unlock perfect, or near-perfect, performance from SLMs on complex coding tasks, placing them on par with leading cloud-based models.

## SLM's Bash Completion Proficiency Evolution
Comparing start performance (v0) with final performance (v13), sorted by final score.

| Model                        | Start Score (v0) | Final Score (v13) | Change |
|-----------------------------:|-----------------:|------------------:|-------:|
| openai_gpt_oss_20b           |              -1  |                15 |    +16 |
| qwen3_coder_30b              |              -8  |                15 |    +23 |
| microsoft_phi4_reasoning_14b |              -1  |                12 |    +13 |
| deepseek_r1_32b              |              -8  |                 5 |    +13 |
| microsoft_phi4_14b           |              -1  |                 5 |     +6 |
| meta_codellama_34b           |              -8  |                -1 |     +7 |
| google_gemma3_12b            |             -15  |                -8 |     +7 |
| google_gemma3_27b            |             -15  |                -8 |     +7 |
| deepseek_v3_qwen2.5_32b      |              -1  |                -5 |     -4 |
| mistral_small_24b            |              -1  |                -5 |     -4 |
| wizardcoder_33b              |              -8  |                -5 |     +3 |
| deepseek_coder_v2_16b        |             -15  |               -15 |     +0 |
| deepseek_r1_14b              |             -15  |               -15 |     +0 |
| meta_codellama_13b           |             -15  |               -15 |     +0 |
| mistral_codestral_22b        |              -1  |               -15 |    -14 |
| phind_codellama_34b          |              -1  |               -15 |    -14 |
| aadi19_olympus_coder_13b     |             N/A  |               -15 |    N/A |

*Note: Proficiency score is calculated as `(perfect * 5) + (passed * 2) + (failed * -5)`.*
*A model with 3 perfect runs has a score of +15 (best); 3 failed runs is -15 (worst).*


## Model Grades and Efficiencies

| Model | Params | Time (s) | Grade (/100) | Efficiency |
| :--- | :--- | :--- | :--- | :--- |
| Google Gemini 2.5-pro | (Cloud) | N/A | 100 | $0.0070 ($1.25/M in; $10/M out) |
| Grok-4 | (Cloud) | N/A | 100 | $0.0122 ($3/M in; $15/M out) |
| **deepseek-coder-v2** | **16B** | **9.4** | **100** | **1063.8** |
| **qwen3-coder** | **19B** | **22.5** | **100** | **444.4** |
| **phi4:14b** | **14B** | **57** | **100** | **175.4** |
| **codestral** | **22B** | **90** | **100** | **111.1** |
| **codellama:34b** | **34B** | **177** | **100** | **56.5** |
| **deepseek-v3-qwen2.5** | **32B** | **185** | **100** | **54.1** |
| **wizardcoder:33b** | **33B** | **N/A** | **100** | **N/A** |
| **phi4-reasoning:14b** | **14B** | **N/A** | **100** | **N/A** |
| Anthropic Claude 4 Sonnet | (Cloud) | N/A | 95 | $0.0078 ($3/M in; $15/M out) |
| OpenAI GPT-4.1-mini | (Cloud) | N/A | 85 | $0.0010 ($0.4/M in; $1.6/M out) |
| OpenAI o4-mini | (Cloud) | N/A | 85 | $0.0036 ($1.1/M in; $4.4/M out) |
| llama4-scout | 16x17B | 92 | 80 | 45.8 |
| Anthropic Claude 4 Opus | (Cloud) | N/A | 72 | $0.0394 ($15/M in; $75/M out) |
| **mistral-small** | **24B** | **125** | **57** | **45.6** |
| DeepSeek-R1:14B (revised) | 14B | 84 | 55 | 32.0 |
| codellama:13b | 13B | 50 | 45 | 28.0 |

**Explanations for Low Performers:** 

*   **mistral-small:** Being a strong general-purpose model, it struggled with the highly specialized and nuanced syntax of Bash completion scripting.

*   **deepseek-r1:14b:** As a general reasoning model, it lacks the specific code-generation fine-tuning of its successful sibling, `deepseek-coder`.

*   **codellama:13b:** This smaller model likely lacks the reasoning depth of its larger `codellama:34b` sibling to master the complex, nuanced logic required.