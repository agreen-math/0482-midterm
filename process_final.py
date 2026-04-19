import argparse
import re
import sys

def get_braced_content(text, start_index=0):
    """
    Extracts content inside nested { }. 
    Returns (content, index_of_closing_brace).
    """
    balance = 1
    i = start_index + 1
    while i < len(text) and balance > 0:
        if text[i] == '{': balance += 1
        elif text[i] == '}': balance -= 1
        i += 1
    if balance == 0:
        return text[start_index+1 : i-1], i
    return "", start_index + 1

def clean_solutions(content):
    """
    Finds all \stxOuttro blocks in this content and extracts the solution text.
    Handles nested braces properly.
    """
    sols = []
    for match in re.finditer(r'\\stxOuttro\s*\{', content):
        sol_content, _ = get_braced_content(content, match.end() - 1)
        # Strip the standard CheckIt "SOLUTION" header text
        sol_content = re.sub(r'^\s*SOLUTION:?\s*', '', sol_content, flags=re.IGNORECASE | re.MULTILINE).strip()
        sols.append(sol_content)
    return "\n\n".join(sols)

def parse_checkit_item(raw_block):
    """
    Parses a top-level CheckIt item using brace-matching logic.
    Identifies single vs multi-part nested knowl structures safely.
    """
    match = re.search(r'\\stxKnowl\s*\{', raw_block)
    if not match: return None
    outer_content, _ = get_braced_content(raw_block, match.end() - 1)

    sub_knowl_iter = list(re.finditer(r'\\item\s*\\stxKnowl\s*\{', outer_content))
    
    if sub_knowl_iter:
        intro_text = outer_content[:sub_knowl_iter[0].start()].strip()
        intro_text = re.sub(r'\\begin\s*\{enumerate\}', '', intro_text).strip()
        
        sub_items = []
        for m in sub_knowl_iter:
            content, _ = get_braced_content(outer_content, m.end() - 1)
            sol = clean_solutions(content)
            q_parts = re.split(r'\\stxOuttro\s*\{', content)
            q_content = q_parts[0].strip()
            sub_items.append({'content': q_content, 'solution': sol})
            
        return {'type': 'multi', 'intro': intro_text, 'sub_items': sub_items}
    else:
        sol = clean_solutions(outer_content)
        q_parts = re.split(r'\\stxOuttro', outer_content)
        q_text = q_parts[0].strip()
        return {'type': 'single', 'content': q_text, 'solution': sol}

def get_math(text, index):
    """
    Safely retrieves a math variable by index.
    """
    math_matches = re.findall(r'\\\[(.*?)\\\]|\\\((.*?)\\\)', text, re.DOTALL)
    math_vars = [m[0].strip() if m[0] else m[1].strip() for m in math_matches]
    if index < len(math_vars):
        return r"\(\displaystyle{ " + math_vars[index] + r" }\)"
    return r"\(\displaystyle{ [\text{MATH MISSING}] }\)"

def format_solution(sol_text):
    """
    Wraps the solution in the department template's 'solution' environment.
    """
    if not sol_text: return ""
    return f"\n\\begin{{solution}}\n{sol_text}\n\\end{{solution}}\n"

def main():
    parser = argparse.ArgumentParser(description="CheckIt to Department LaTeX Parser - Web Final")
    parser.add_argument("--checkit", required=True, help="Input CheckIt .tex file")
    parser.add_argument("--template", required=True, help="Input Department Template .tex file")
    parser.add_argument("--out", required=True, help="Output .tex file")
    args = parser.parse_args()

    with open(args.checkit, 'r', encoding='utf-8') as f:
        checkit_content = f.read()

    # Safely isolate the top-level CheckIt items
    raw_blocks = re.split(r'\\item\s*%%%%% SpaTeXt Commands %%%%%', checkit_content)
    if len(raw_blocks) > 0: 
        raw_blocks = raw_blocks[1:]

    parsed_items = []
    for block in raw_blocks:
        if '\\stxKnowl' in block:
            item = parse_checkit_item(block)
            if item: parsed_items.append(item)

    # Validate that we successfully parsed exactly 20 items
    q_items = []
    for i in range(20):
        if i < len(parsed_items):
            q_items.append(parsed_items[i])
        else:
            print(f"Warning: Expected item at index {i} but did not find it.")
            q_items.append({'type': 'single', 'content': 'MISSING', 'solution': ''})

    questions = []

    # Q1
    q1 = r"\question[5] Determine the GCF (Greatest Common Factor) of the following expressions.\\ \\ " + get_math(q_items[0]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[0]['solution'])
    questions.append(q1)

    # Q2
    q2 = r"\question[5] Factor out the GCF from the polynomial completely.\\ \\ " + get_math(q_items[1]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[1]['solution'])
    questions.append(q2)

    # Q3
    q3 = r"\question[5] Factor the polynomial by grouping.\\ \\ " + get_math(q_items[2]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[2]['solution'])
    questions.append(q3)

    # Q4
    q4 = r"\question[5] Factor the polynomial completely.\\ \\ " + get_math(q_items[3]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[3]['solution'])
    questions.append(q4)

    # Q5
    q5 = r"\question[5] Factor the polynomial completely.\\ \\ " + get_math(q_items[4]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[4]['solution'])
    questions.append(q5)

    # Q6
    q6 = r"\question[5] Factor the polynomial completely.\\ \\ " + get_math(q_items[5]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[5]['solution'])
    questions.append(q6)

    # Q7
    q7 = r"\question[5] Solve the polynomial equation by factoring.\\ \\ " + get_math(q_items[6]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[6]['solution'])
    questions.append(q7)

    # Q8
    q8 = r"\question[5] Solve the polynomial equation by factoring.\\ \\ " + get_math(q_items[7]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[7]['solution'])
    questions.append(q8)

    # Q9
    q9 = r"\question[5] Find a polynomial equation with integer coefficients given the solutions: " + get_math(q_items[8]['content'], 0) + r"." + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[8]['solution'])
    questions.append(q9)

    # Q10
    q10 = r"\question[5] Given " + get_math(q_items[9]['content'], 0) + r", simplify " + get_math(q_items[9]['content'], 1) + r" when " + get_math(q_items[9]['content'], 2) + r"." + "\n" + r"\vspace*{\stretch{2}}\answerline" + format_solution(q_items[9]['solution'])
    questions.append(q10)

    # Q11
    q11 = r"\question[5] Solve the rational equation.\\ \\ " + get_math(q_items[10]['content'], 0) + "\n" + r"\vspace*{\stretch{2}}\answerline" + format_solution(q_items[10]['solution'])
    questions.append(q11)

    # Q12
    q12 = r"\question[5] Simplify the radical expression completely.\\ \\ " + get_math(q_items[11]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[11]['solution'])
    questions.append(q12)

    # Q13 (Includes the Instruction Block)
    inst_rad = r"\uplevel{\textbf{For Problems \ref{rad-simp-begin} through \ref{rad-simp-end}, perform the operations and simplify. Assume all variables are positive and rationalize the denominator when appropriate.}}" + "\n\n"
    q13 = inst_rad + r"\question[5]\label{rad-simp-begin} " + get_math(q_items[12]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[12]['solution'])
    questions.append(q13)

    # Q14
    q14 = r"\question[5] " + get_math(q_items[13]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[13]['solution'])
    questions.append(q14)

    # Q15
    q15 = r"\question[5]\label{rad-simp-end} " + get_math(q_items[14]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[14]['solution'])
    questions.append(q15)

    # Q16
    q16 = r"\question[5] Solve for all solutions.\\ \\ " + get_math(q_items[15]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[15]['solution'])
    questions.append(q16)

    # Q17
    q17 = r"\question[5] Solve for all solutions.\\ \\ " + get_math(q_items[16]['content'], 0) + "\n" + r"\vspace*{\stretch{2.5}}\answerline" + format_solution(q_items[16]['solution'])
    questions.append(q17)

    # Q18
    q18 = r"\question[5] Solve for all solutions.\\ \\ " + get_math(q_items[17]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[17]['solution'])
    questions.append(q18)

    # Q19
    q19 = r"\question[5] Solve for all solutions. \\ \\ " + get_math(q_items[18]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[18]['solution'])
    questions.append(q19)

    # Q20
    q20 = r"\question[5] Solve using the quadratic formula. \\ \\ " + get_math(q_items[19]['content'], 0) + "\n" + r"\vspace*{\stretch{1}}\answerline" + format_solution(q_items[19]['solution'])
    questions.append(q20)

    # Apply exact page breaks matching the standard Web Final template layout
    page_breaks = [1, 3, 5, 8, 11, 12, 14, 16, 18]
    for idx in page_breaks:
        if idx < len(questions):
            questions[idx] += "\n\\newpage\n"

    # Inject into template
    with open(args.template, 'r', encoding='utf-8') as f:
        template_content = f.read()

    parts = re.split(r'\\begin\{questions\}|\\end\{questions\}', template_content)
    
    if len(parts) != 3:
        print("Error: Could not locate exactly one begin/end questions environment in the template.")
        sys.exit(1)

    final_latex = parts[0] + r"\begin{questions}" + "\n\n"
    final_latex += "\n\n".join(questions)
    final_latex += "\n\n" + r"\end{questions}" + parts[2]

    with open(args.out, 'w', encoding='utf-8') as f:
        f.write(final_latex)

    print(f"Successfully parsed and built exam. Output saved to {args.out}")

if __name__ == "__main__":
    main()