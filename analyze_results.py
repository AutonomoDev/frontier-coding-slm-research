import re
import csv
from collections import defaultdict

def analyze_and_grade_results(
    input_file='final_results.txt', 
    output_txt='final_grades.txt',
    output_summary_csv='final_results_summary.csv',
    output_grades_csv='final_results_grades.csv'
):
    """
    Analyzes model test results for multiple versions, generating three reports with
    mutually exclusive categories for Perfect, Passing, and Failing models, and tracks
    the first milestone of a single perfect run.
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

    sorted_versions = sorted(version_stats.keys(), key=lambda v: int(v[1:]))

    for version in sorted_versions:
        for model, stats in version_stats[version].items():
            all_model_names.add(model)
            passed = stats.get('passed', 0)
            failed = stats.get('failed', 0)
            perfect = stats.get('perfect', 0)
            
            # --- *** NEW: Track the milestone for the very first perfect run (>= 1) *** ---
            # This is independent of the main summary logic below.
            if perfect >= 1 and model not in first_ever_perfect_run:
                first_ever_perfect_run[model] = version

            # --- Main Summary Logic (mutually exclusive) ---
            # 1. Check for the highest category: Perfect Model (>= 2 perfect runs)
            if perfect >= 2:
                version_summaries[version]['perfect'] += 1
            # 2. If not Perfect, check for Passing (>= 2 passed or perfect runs)
            elif (passed + perfect) >= 2:
                version_summaries[version]['passing'] += 1
            # 3. If neither, it is Failing
            else:
                version_summaries[version]['failing'] += 1
                
            # Grading Logic (remains the same):
            score = (perfect * 5) + (passed * 2) + (failed * -5)
            grades_data[model][version] = score

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

        # *** UPDATED: "First to Perfect" Table with new definition ***
        f_out.write("--- Milestone: First Version a Model Achieved ANY Perfect Run (>= 1) ---\n")
        if not first_ever_perfect_run:
            f_out.write("No models achieved a perfect run in any version.\n")
        else:
            for model in sorted(first_ever_perfect_run.keys()):
                version = first_ever_perfect_run[model]
                f_out.write(f"{model}: {version}\n")
        
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
    sorted_models = sorted(list(all_model_names))
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

if __name__ == "__main__":
    analyze_and_grade_results()
