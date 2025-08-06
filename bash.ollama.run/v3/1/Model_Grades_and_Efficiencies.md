## Model Grades and Efficiencies (Bash: ollama run) - Round 1 

| Model                     | Params  | Time (s) | Cost    | Grade (Quality) | Grade (Functional) | Efficiency |
|---------------------------|---------|----------|---------|-----------------|--------------------|------------|
| Google Gemini 2.5-pro     | (Cloud) |          | $0.0070 | 100             | 100                | **95.3**   |
| qwen3-coder               | 19B     | 22.5     |         | 82              | 90                 | **91.0**   |
| OpenAI o3                 | (Cloud) |          | $0.0063 | 90              | 92                 | **89.9**   |
| Anthropic Claude 4 Sonnet | (Cloud) |          | $0.0078 | 95              | 70                 | **78.7**   |
| OpenAI GPT-4.1-mini       | (Cloud) |          | $0.0010 | 85              | 50                 | **72.0**   |
| codestral                 | 22B     | 90       |         | 88              | 50                 | **70.1**   |
| Grok-4                    | (Cloud) |          | $0.0122 | 100             | 50                 | **66.2**   |
| Anthropic Claude 4 Opus   | (Cloud) |          | $0.0394 | 72              | 100                | **64.4**   |
| codellama:13b             | 13B     | 50       |         | 45              | 45                 | **60.2**   |
| OpenAI o4-mini            | (Cloud) |          | $0.0036 | 85              | 25                 | **57.5**   |
| codellama:34b             | 34B     | 177      |         | 50              | 40                 | **54.8**   |
| deepseek-coder-v2         | 16B     | 9.4      |         | 60              | 25                 | **54.5**   |
| wizardcoder:33b           | 33B     | 183      |         | 70              | 30                 | **53.6**   |
| deepseek-r1:32b           | 32B     | 323      |         | 65              | 35                 | **50.8**   |
| deepseek-v3-qwen2.5       | 32B     | 185      |         | 85              | 10                 | **46.5**   |
| deepseek-r1               | 14B     | 84       |         | 55              | 10                 | **43.7**   |
| phi4                      | 14B     | 57       |         | 75              | 0                  | **43.5**   |
| mistral-small             | 14B     | 125      |         | 60              | 10                 | **43.4**   |

---

## Model Efficiency Calculation Equations

$$
\boxed{
\begin{aligned}
\text{Normalized Time Score} &= 100 \times \frac{T_{\max} - T}{T_{\max} - T_{\min}} \\
\text{Efficiency} &= 0.5 \times \text{Functional Grade} + 0.3 \times \text{Normalized Time Score} + 0.2 \times \text{Quality Grade}
\end{aligned}
}
$$

Efficiency = (0.5 × Functional Grade) + (0.3 × Normalized Time/Cost Score) + (0.2 × Quality Grade)

**Google Gemini 2.5-pro**
Normalized Cost Score = 84.38
Efficiency = (0.5 × 100) + (0.3 × 84.38) + (0.2 × 100) = 50.00 + 25.31 + 20.00 = 95.31

**qwen3-coder**
Normalized Time Score = 98.64
Efficiency = (0.5 × 90) + (0.3 × 98.64) + (0.2 × 82) = 45.00 + 29.59 + 16.40 = 90.99

**Anthropic Claude 4 Sonnet**
Normalized Cost Score = 82.29
Efficiency = (0.5 × 70) + (0.3 × 82.29) + (0.2 × 95) = 35.00 + 24.69 + 19.00 = 78.69

**OpenAI GPT-4.1-mini**
Normalized Cost Score = 100.00
Efficiency = (0.5 × 50) + (0.3 × 100.00) + (0.2 × 85) = 25.00 + 30.00 + 17.00 = 72.00

**codestral**
Normalized Time Score = 91.63
Efficiency = (0.5 × 50) + (0.3 × 91.63) + (0.2 × 88) = 25.00 + 27.49 + 17.60 = 70.09

**Grok-4**
Normalized Cost Score = 70.83
Efficiency = (0.5 × 50) + (0.3 × 70.83) + (0.2 × 100) = 25.00 + 21.25 + 20.00 = 66.25

**Anthropic Claude 4 Opus**
Normalized Cost Score = 0.00
Efficiency = (0.5 × 100) + (0.3 × 0.00) + (0.2 × 72) = 50.00 + 0.00 + 14.40 = 64.40

**codellama:13b**
Normalized Time Score = 95.78
Efficiency = (0.5 × 45) + (0.3 × 95.78) + (0.2 × 45) = 22.50 + 28.73 + 9.00 = 60.23

**OpenAI o4-mini**
Normalized Cost Score = 93.23
Efficiency = (0.5 × 25) + (0.3 × 93.23) + (0.2 × 85) = 12.50 + 27.97 + 17.00 = 57.47

**codellama:34b**
Normalized Time Score = 82.59
Efficiency = (0.5 × 40) + (0.3 × 82.59) + (0.2 × 50) = 20.00 + 24.78 + 10.00 = 54.78

**deepseek-coder-v2**
Normalized Time Score = 100.00
Efficiency = (0.5 × 25) + (0.3 × 100.00) + (0.2 × 60) = 12.50 + 30.00 + 12.00 = 54.50

**deepseek-v3-qwen2.5**
Normalized Time Score = 81.76
Efficiency = (0.5 × 10) + (0.3 × 81.76) + (0.2 × 85) = 5.00 + 24.53 + 17.00 = 46.53

**DeepSeek-R1:14B (revised)**
Normalized Time Score = 92.25
Efficiency = (0.5 × 10) + (0.3 × 92.25) + (0.2 × 55) = 5.00 + 27.68 + 11.00 = 43.68

**phi4:14b**
Normalized Time Score = 95.06
Efficiency = (0.5 × 0) + (0.3 × 95.06) + (0.2 × 75) = 0.00 + 28.52 + 15.00 = 43.52

**mistral-small**
Normalized Time Score = 87.99
Efficiency = (0.5 × 10) + (0.3 × 87.99) + (0.2 × 60) = 5.00 + 26.40 + 12.00 = 43.40

**OpenAI o3**
Normalized Cost Score = 86.20
Efficiency = (0.5 × 92) + (0.3 × 86.20) + (0.2 × 90) = 46.00 + 25.86 + 18.00 = 89.86

**wizardcoder:33b**
Normalized Time Score = 81.97
Efficiency = (0.5 × 30) + (0.3 × 81.97) + (0.2 × 70) = 15.00 + 24.59 + 14.00 = 53.59

**deepseek-r1:32b**
Normalized Time Score = 67.49
Efficiency = (0.5 × 35) + (0.3 × 67.49) + (0.2 × 65) = 17.50 + 20.25 + 13.00 = 50.75
