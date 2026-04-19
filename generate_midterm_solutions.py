import re
import sys
import os

def generate_solution_version(input_file, output_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # ---------------------------------------------------------
    # 1. Update Global Header Information
    # ---------------------------------------------------------
    # Change \noprintanswers to %\noprintanswers
    content = re.sub(r'^\s*\\noprintanswers', r'%\\noprintanswers', content, flags=re.MULTILINE)
    
    # Change %\printanswers to \printanswers
    content = re.sub(r'^\s*%\\printanswers', r'\\printanswers', content, flags=re.MULTILINE)
    
    # Update course string: "MATH 0482" -> "0482"
    content = re.sub(r'\\newcommand\{\\course\}\{MATH 0482 (.*?)\}', r'\\newcommand{\\course}{0482 \1}', content)

    # ---------------------------------------------------------
    # 2. Reformat Question 11 (Linear Graphing Table)
    # ---------------------------------------------------------
    # Finds the \begin{multicols}{2} ... \end{multicols} block and comments it out
    q11_pattern = re.compile(
        r'(\\question\[5\] Graph and identify the slope and \$y\$-intercept:.*?)(^\\begin\{multicols\}\{2\}.*?^\\end\{multicols\})',
        re.DOTALL | re.MULTILINE
    )
    
    def q11_repl(match):
        prefix = match.group(1)
        multicol_block = match.group(2)
        # Add a % to the start of every line in the multicol block
        commented_block = "\n".join("% " + line for line in multicol_block.splitlines())
        return prefix + commented_block

    content = q11_pattern.sub(q11_repl, content)

    # ---------------------------------------------------------
    # 3. Reformat Questions 13 & 14 (Domain/Range Checkboxes)
    # ---------------------------------------------------------
    # Moves the solution block inside the multicolumn and comments out the checkboxes/table
    q13_14_pattern = re.compile(
        r'(\\question\[5\]\\label\{func-\d+\}\s*\\,\s*\n\s*\\begin\{multicols\}\{2\})\s*\n(.*?)\\columnbreak(.*?)\\end\{multicols\}\s*\n\s*\\begin\{solution\}(.*?)\\end\{solution\}',
        re.DOTALL
    )
    
    def q13_14_repl(match):
        header = match.group(1)            # \question ... \begin{multicols}{2}
        checkboxes_table = match.group(2)  # Checkbox and tabular code
        graph_code = match.group(3)        # TikZ code
        solution_content = match.group(4)  # Solution itemize list

        # Comment out the checkboxes and table
        commented_table = "\n".join("% " + line for line in checkboxes_table.strip().splitlines())

        # Rebuild the block with the solution at the top
        return (f"{header}\n\n"
                f"\\begin{{solution}}{solution_content}\\end{{solution}}\n"
                f"\\vspace{{\\stretch{{1}}}}\n\n"
                f"{commented_table}\n\n"
                f"\\columnbreak{graph_code}\\end{{multicols}}")

    content = q13_14_pattern.sub(q13_14_repl, content)

    # ---------------------------------------------------------
    # 4. Reformat Question 15 (Reading Graph Values)
    # ---------------------------------------------------------
    # Injects the answers into the \fillin commands and wraps the parts in a solution environment
    q15_pattern = re.compile(
        r'(Given the graph of the function \$f\$.*?\\columnbreak\s*\n\s*)(\\begin\{parts\}.*?\\end\{parts\})(\s*\n\s*\\end\{multicols\}\s*\n\s*)(\\begin\{solution\}.*?\\end\{solution\})',
        re.DOTALL
    )
    
    def q15_repl(match):
        prefix = match.group(1)
        parts_block = match.group(2)
        mid_space = match.group(3)
        sol_block_full = match.group(4)

        # Extract the answers from the solution itemize list (e.g. \( -3 \))
        answers = []
        for raw_ans in re.findall(r'\([a-z]\)\s*\\\((.*?)\\\)', sol_block_full):
            ans = raw_ans.replace('x = ', '').strip()
            answers.append(ans)

        # Safely replace \fillin sequentially from left-to-right
        ans_iter = iter(answers)
        def replace_fillin(m):
            try:
                ans = next(ans_iter)
                return rf'\fillin[{ans}]'
            except StopIteration:
                return r'\fillin'  # Fallback if there are more \fillin's than parsed answers
                
        parts_block = re.sub(r'\\fillin', replace_fillin, parts_block)

        # Wrap the populated parts block in a solution environment
        new_parts = f"\\begin{{solution}}\n{parts_block}\n\\end{{solution}}"
        
        # Comment out the original solution block at the bottom
        commented_sol = "\n".join("% " + line for line in sol_block_full.splitlines())

        return f"{prefix}{new_parts}{mid_space}{commented_sol}"

    content = q15_pattern.sub(q15_repl, content)

    # Write the final reformatted content to the output file
    with open(output_file, 'w') as f:
        f.write(content)

    print(f"Successfully generated {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_solutions.py <input_file.tex> <output_file.tex>")
        print("Example: python generate_solutions.py SP26B.tex SP26B_SOL.tex")
    else:
        input_filepath = sys.argv[1]
        output_filepath = sys.argv[2]
        
        if not os.path.exists(input_filepath):
            print(f"Error: Could not find input file '{input_filepath}'")
        else:
            generate_solution_version(input_filepath, output_filepath)