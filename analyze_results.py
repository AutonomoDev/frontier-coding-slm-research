#!/bin/env python
# ==== analyze_results.py ====
import re
import csv
from collections import defaultdict

def analyze_and_grade_results(
    input_file='final_results.txt', 
    output_txt='final_grades.txt',
    output_summary_csv='final_results_summary.csv',
    output_grades_csv='final_results_grades.csv',
    output_evolution_csv='slm_proficiency_evolution.csv'
):
    """
    Analyzes model test results for multiple versions, generating reports on
    performance, grades, and proficiency evolution over time.
    """
    # --- 1. PARSING THE INPUT FILE ---
    version_stats = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))
    filename_pattern = re.compile(r'prompt\.v\d+-\d+\.(.+)\.sh$')
    version_pattern = re.compile(r'├──\s+(v\d+)')
    current_version = None
    current_status = None

    try:
        with open(input_file, 'r') as f_in:
            for line in f_in:
                stripped_line = line.strip()
                version_match = version_pattern.search(line)
                
                if version_match:
                    current_version = version_match.group(1)
                    continue
                if not current_version:
                    continue

                if ' passed' in stripped_line:
                    current_status = 'passed'
                elif ' failed' in stripped_line:
                    current_status = 'failed'
                elif ' perfect' in stripped_line:
                    current_status = 'perfect'
                
                if stripped_line.endswith('.sh'):
                    filename = stripped_line.split()[-1]
                    match = filename_pattern.search(filename)
                    if match and current_status:
                        model_name = match.group(1)
                        version_stats[current_version][model_name][current_status] += 1
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        return

    # --- 2. PROCESSING THE PARSED DATA FOR SUMMARIES AND GRADES ---
    version_summaries = defaultdict(lambda: defaultdict(int))
    grades_data = defaultdict(dict)
    first_ever_perfect_run = {}
    all_model_names = set()

    if not version_stats:
        print("Warning: No data parsed from the input file. Output files will be empty.")
        for f in [output_txt, output_summary_csv, output_grades_csv, output_evolution_csv]:
            open(f, 'w').close()
        return

    sorted_versions = sorted(version_stats.keys(), key=lambda v: int(v[1:]))
    
    start_version = sorted_versions[0] if sorted_versions else None
    final_version = sorted_versions[-1] if sorted_versions else None

    for version in sorted_versions:
        for model, stats in version_stats[version].items():
            all_model_names.add(model)
            passed = stats.get('passed', 0)
            failed = stats.get('failed', 0)
            perfect = stats.get('perfect', 0)
            
            if perfect >= 1 and model not in first_ever_perfect_run:
                first_ever_perfect_run[model] = version

            if perfect >= 2:
                version_summaries[version]['perfect'] += 1
            elif (passed + perfect) >= 2:
                version_summaries[version]['passing'] += 1
            else:
                version_summaries[version]['failing'] += 1
                
            score = (perfect * 5) + (passed * 2) + (failed * -5)
            grades_data[model][version] = score
    
    # --- Prepare data for the Proficiency Evolution report ---
    evolution_data = []
    sorted_models = sorted(list(all_model_names))
    if start_version and final_version:
        for model in sorted_models:
            start_score = grades_data[model].get(start_version, 'N/A')
            final_score = grades_data[model].get(final_version, 'N/A')
            
            change = 'N/A'
            if isinstance(start_score, int) and isinstance(final_score, int):
                change = final_score - start_score
            
            evolution_data.append({
                'model': model,
                'start_score': start_score,
                'final_score': final_score,
                'change': change
            })
        
        # --- *** NEW: Sort by final score, descending *** ---
        # Models with 'N/A' score will be at the bottom.
        evolution_data.sort(
            key=lambda item: item['final_score'] if isinstance(item['final_score'], int) else -float('inf'),
            reverse=True
        )

    # --- 3. WRITING THE OUTPUT FILES ---

    # 3.1. Write final_grades.txt
    with open(output_txt, 'w') as f_out:
        f_out.write("--- Version Summary ---\n")
        f_out.write("Model Classifications (mutually exclusive):\n")
        f_out.write("- 'Perfect': Model has >= 2 perfect runs.\n")
        f_out.write("- 'Passing': Model is not Perfect and has >= 2 passed/perfect runs.\n")
        f_out.write("- 'Failing': Model is neither Perfect nor Passing.\n\n")
        
        for version in sorted_versions:
            summary = version_summaries[version]
            f_out.write(
                f"{version}:  {summary['failing']} failing, "
                f"{summary['passing']} passing, "
                f"{summary['perfect']} perfect.\n"
            )
        f_out.write("\n" + "="*60 + "\n\n")

        f_out.write("--- Milestone: First Version a Model Achieved ANY Perfect Run (>= 1) ---\n")
        if not first_ever_perfect_run:
            f_out.write("No models achieved a perfect run in any version.\n")
        else:
            for model in sorted(first_ever_perfect_run.keys()):
                version = first_ever_perfect_run[model]
                f_out.write(f"{model}: {version}\n")
        f_out.write("\n" + "="*60 + "\n\n")

        # --- *** UPDATED: SLM Proficiency Evolution Section with Markdown Table *** ---
        f_out.write("--- SLM's Bash Completion Proficiency Evolution ---\n")
        if evolution_data:
            f_out.write(f"Comparing start performance ({start_version}) with final performance ({final_version}), sorted by final score.\n\n")
            
            # Write Markdown table header
            f_out.write(f"| Model | Start Score ({start_version}) | Final Score ({final_version}) | Change |\n")
            f_out.write(f"|---|---|---|---|\n")

            # Write Markdown table rows
            for item in evolution_data:
                change_str = f"{item['change']:+}" if isinstance(item['change'], int) else "N/A"
                f_out.write(
                    f"| {item['model']} | {item['start_score']} | {item['final_score']} | {change_str} |\n"
                )
            
            # --- *** NEW: Add explanatory note *** ---
            f_out.write("\n*Note: Proficiency score is calculated as `(perfect * 5) + (passed * 2) + (failed * -5)`.*\n")
            f_out.write("*A model with 3 perfect runs has a score of +15 (best); 3 failed runs is -15 (worst).*\n")

        else:
            f_out.write("Not enough version data to compare evolution.\n")
        f_out.write("\n" + "="*60 + "\n\n")

        f_out.write("--- Detailed Breakdown by Version ---\n\n")
        for version in sorted_versions:
            f_out.write(f"--- Results for {version} ---\n")
            model_data = version_stats[version]
            for model_name in sorted(model_data.keys()):
                stats = model_data[model_name]
                p, f, pf = stats.get('passed', 0), stats.get('failed', 0), stats.get('perfect', 0)
                f_out.write(f"{model_name} (passed: {p}, failed: {f}, perfect: {pf})\n")
            f_out.write("\n")
    print(f"Detailed report with summary written to '{output_txt}'.")

    # 3.2. Write final_results_summary.csv
    with open(output_summary_csv, 'w', newline='') as f_csv:
        writer = csv.writer(f_csv)
        writer.writerow(['Version', 'Failing Models', 'Passing Models', 'Perfect Models'])
        for version in sorted_versions:
            summary = version_summaries[version]
            writer.writerow([version, summary['failing'], summary['passing'], summary['perfect']])
    print(f"Version summary CSV written to '{output_summary_csv}'.")

    # 3.3. Write final_results_grades.csv
    with open(output_grades_csv, 'w', newline='') as f_csv:
        writer = csv.writer(f_csv)
        header = ['Model'] + sorted_versions
        writer.writerow(header)
        for model in sorted_models:
            row = [model]
            for version in sorted_versions:
                score = grades_data[model].get(version, 'N/A')
                row.append(score)
            writer.writerow(row)
    print(f"Model grade sheet CSV written to '{output_grades_csv}'.")

    # 3.4. Write slm_proficiency_evolution.csv (now sorted)
    if evolution_data:
        with open(output_evolution_csv, 'w', newline='') as f_csv:
            header = [
                'Model',
                f'Start Score ({start_version})',
                f'Final Score ({final_version})',
                'Score Change'
            ]
            writer = csv.writer(f_csv)
            writer.writerow(header)
            
            for item in evolution_data:
                writer.writerow([
                    item['model'],
                    item['start_score'],
                    item['final_score'],
                    item['change']
                ])
        print(f"Proficiency evolution CSV written to '{output_evolution_csv}'.")

if __name__ == "__main__":
    analyze_and_grade_results()
