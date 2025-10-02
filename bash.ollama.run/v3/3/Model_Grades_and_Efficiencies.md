## Model Grades and Efficiencies (Bash: ollama run) - Round 1 

| Model       | Params | Time (s) | Grade (Quality) | Grade (Functional) | Efficiency |
|-------------|--------|----------|-----------------|--------------------|------------|
| gpt-oss:22b | 22B    | 647      | 92              | 100                | **78.5**   |

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

**gpt-oss:22b**
Normalized Time Score = 33.77
Efficiency = (0.5 × 100) + (0.3 × 33.77) + (0.2 × 92) = 50.00 + 10.13 + 18.40 = 78.53
