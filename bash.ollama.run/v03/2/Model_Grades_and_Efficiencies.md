## Model Grades and Efficiencies (Bash: ollama run) - Round 1 

| Model               | Params | Time (s) | Grade (Quality) | Grade (Functional) | Efficiency |
|---------------------|--------|----------|-----------------|--------------------|------------|
| qwen3-coder         | 19B    | 56       | 82              | 90                 | **90.3**   |
| codestral:22b       | 22B    | 90       | 85              | 0                  | **43.2**   |
| gemma3:12b          | 12B    | 43       | 80              | 0                  | **43.6**   |
| phi4:14b            | 14B    | 57       | 70              | 0                  | **41.8**   |
| codellama:13b       | 13B    | 29       | 45              | 0                  | **37.8**   |
| mistral-small:24b   | 24B    | 125      | 65              | 0                  | **37.6**   |
| codellama:34b       | 34B    | 173      | 50              | 0                  | **37.0**   |
| wizardcoder:33b     | 33B    | 171      | 70              | 0                  | **36.4**   |
| phind-codellama:34b | 34B    | 144      | 60              | 0                  | **35.7**   |
| gpt-oss:20b         | 20B    | 372      | 90              | 0                  | **30.9**   |
| deepseek-coder-v2   | 16B    | 16       | 0               | 0                  | **30.0**   |
| gemma3:27b          | 27B    | 201      | 70              | 0                  | **27.6**   |
| codellama:34b       | 34B    | 173      | 50              | 0                  | **26.1**   |
| deepseek-r1:14b     | 14B    | 72       | 0               | 0                  | **25.1**   |
| deepseek-v3-qwen2.5 | 32B    | 138      | 0               | 0                  | **19.2**   |
| deepseek-r1:32b     | 32B    | 355      | 0               | 0                  | **0.0**    |




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

**qwen3-coder**
Normalized Time Score = 88.20
Efficiency = (0.5 × 90) + (0.3 × 88.20) + (0.2 × 82) = 87.86

**deepseek-coder-v2**
Normalized Time Score = (355 – 16) / (355 – 16) × 100 = 100.00
Efficiency = (0.5 × 0) + (0.3 × 100.00) + (0.2 × 0) = 0 + 30.00 + 0 = **30.00**

**deepseek-r1:14b**
Normalized Time Score = (355 – 72) / 339 × 100 = 83.54
Efficiency = (0.5 × 0) + (0.3 × 83.54) + (0.2 × 0) = 0 + 25.06 + 0 = **25.06**

**deepseek-r1:32b**
Normalized Time Score = (355 – 355) / 339 × 100 = 0.00
Efficiency = (0.5 × 0) + (0.3 × 0.00) + (0.2 × 0) = 0 + 0.00 + 0 = **0.00**

**deepseek-v3-qwen2.5**
Normalized Time Score = (355 – 138) / 339 × 100 = 64.01
Efficiency = (0.5 × 0) + (0.3 × 64.01) + (0.2 × 0) = 0 + 19.20 + 0 = **19.20**


