import re
import sys

# ==========================================
# 1. PARSING LOGIC
# ==========================================

def get_braced_content(text, start_index=0):
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
    """Extracts solution content from CheckIt format."""
    # Find the start of the solution block
    sol_match = re.search(r'\\stxOuttro\s*\{', content)
    if not sol_match:
        return ""
    
    sol_content, _ = get_braced_content(content, sol_match.end() - 1)
    
    # Clean up title and whitespace
    sol_content = re.sub(r'^\s*SOLUTION\s*', '', sol_content, flags=re.IGNORECASE | re.MULTILINE).strip()
    return sol_content

def parse_checkit_item(raw_block):
    """Parses a CheckIt item block into content and solution."""
    match = re.search(r'\\stxKnowl\s*\{', raw_block)
    if not match: return None
    
    outer_content, _ = get_braced_content(raw_block, match.end() - 1)
    
    # Check for nested knowls (like the Q13/14 combined item or Q12 parts)
    sub_knowls_matches = list(re.finditer(r'\\item\s*\\stxKnowl\s*\{', outer_content))
    
    if sub_knowls_matches:
        # This is a multi-part item
        sub_items = []
        for m in sub_knowls_matches:
            content, end = get_braced_content(outer_content, m.end() - 1)
            sol = clean_solutions(content)
            
            # Remove solution block from content for display
            clean_q = re.sub(r'\\stxOuttro\s*\{.*?\}', '', content, flags=re.DOTALL).strip()
            if clean_q.endswith('}'): clean_q = clean_q[:-1]
            
            sub_items.append({'content': clean_q, 'solution': sol})
            
        return {'type': 'multi', 'sub_items': sub_items, 'raw': outer_content}

    else:
        # Standard Single Item
        sol = clean_solutions(outer_content)
        
        # Remove solution from question text
        q_parts = re.split(r'\\stxOuttro', outer_content)
        q_text = q_parts[0].strip()
        
        return {'type': 'single', 'content': q_text, 'solution': sol}

# ==========================================
# 2. FORMATTING FUNCTIONS
# ==========================================

def latex_norm(text):
    """Normalize CheckIt brackets to standard LaTeX math delimiters."""
    if not text: return ""
    text = text.replace(r"\(", "$").replace(r"\)", "$")
    text = text.replace(r"\[", "$$").replace(r"\]", "$$")
    return text

def format_standard(item, points=5, space=1):
    # Safety check for multi-items passed to standard formatter
    if item['type'] == 'multi':
        # Fallback: join sub-items if accidentally routed here
        q = " ".join([si['content'] for si in item['sub_items']])
        sol = "\n".join([si['solution'] for si in item['sub_items']])
    else:
        q = item['content']
        sol = item['solution']
    
    q = latex_norm(q)
    
    return fR"""
\question[{points}] {q}
\begin{{solution}}
{sol}
\end{{solution}}
\vspace{{\stretch{{{space}}}}}\answerline
"""

def format_q11_graphing(item):
    """Q11: Linear Graphing with Table layout."""
    if item['type'] == 'multi':
         q_text = item['sub_items'][0]['content']
         sol_text = item['sub_items'][0]['solution']
    else:
         q_text = item['content']
         sol_text = item['solution']
    
    # Extract function equation
    func_match = re.search(r'\\\(.*?(f\(x\)|y)\s*=\s*(.*?)\\\)', q_text)
    if func_match:
        func_eqn = f"${func_match.group(1)} = {func_match.group(2)}$"
    else:
        math_match = re.search(r'\\\(.*?\\\)', q_text)
        func_eqn = math_match.group(0).replace(r"\(", "$").replace(r"\)", "$") if math_match else q_text

    return fR"""
\question[5] Graph and identify the slope and $y$-intercept: \\

{func_eqn}

\begin{{multicols}}{{2}}
{{\renewcommand{{\arraystretch}}{{2.5}}%
\begin{{tabular}}{{|c|p{{1.5in}}|}}\hline
    slope &  \\ \hline
    $y$-int &  \\ \hline
    $x$-int & \\ \hline
\end{{tabular}}}}

\vspace{{\stretch{{1}}}}

\columnbreak
\includegraphics[width=3.5in]{{blankgraph.PNG}}

\end{{multicols}}

\begin{{solution}}
{sol_text}
\end{{solution}}
"""

def format_q12_eval(item):
    """Q12: Evaluation parts. Handles both Single (enumerate inside) and Multi (nested knowls)."""
    if item['type'] == 'single':
        q = latex_norm(item['content'])
        sol = item['solution']
        return fR"""
\question[5] {q}
\begin{{solution}}
{sol}
\end{{solution}}
"""
    else:
        # Multi-part case (CheckIt nested knowls)
        # 1. Extract Intro (everything before \begin{enumerate})
        raw = item['raw']
        intro_parts = re.split(r'\\begin\s*\{enumerate\}', raw)
        intro = latex_norm(intro_parts[0].strip()) if intro_parts else "Evaluate:"
        
        # 2. Build Parts
        parts_out = "\\begin{parts}\n"
        for sub in item['sub_items']:
            q_sub = latex_norm(sub['content'])
            sol_sub = sub['solution']
            parts_out += fR"\part {q_sub}\n\begin{{solution}}\n{sol_sub}\n\end{{solution}}\n\vspace{{\stretch{{1}}}}\answerline\n"
        parts_out += "\\end{parts}"
        
        return fR"""
\question[5] {intro}
{parts_out}
"""

def format_q13_14_combined(item):
    """
    Handles the combined Function/Domain/Range item.
    Splits it into two separate question blocks (Part A and Part B).
    """
    if item['type'] != 'multi':
        return r"\question[5] Error: Expected multi-part item for Q13/14."
    
    output = ""
    
    # Process each sub-item as its own question block
    for i, sub in enumerate(item['sub_items']):
        graph = sub['content']
        sol = sub['solution']
        
        output += fR"""
\question[5] Determine whether the relation represents a function.

\begin{{multicols}}{{2}}

Function: \begin{{oneparcheckboxes}} \choice Yes \choice No \end{{oneparcheckboxes}}\\
\vspace{{.25in}} \\
\vspace{{.25in}}Explain: \hrulefill \\
\vspace{{.25in}}\hrulefill

{{\renewcommand{{\arraystretch}}{{2}}%
\begin{{tabular}}{{|c|p{{1.5in}}|}}\hline
    Domain &  \\ \hline
    Range & \\ \hline
\end{{tabular}}}}

\vspace{{\stretch{{1}}}}

\columnbreak
\centering
{graph}

\end{{multicols}}

\begin{{solution}}
{sol}
\end{{solution}}
\newpage
"""
    return output

def format_q15_reading(item):
    """Q15: Reading graph values."""
    if item['type'] == 'multi':
        q_text = " ".join([si['content'] for si in item['sub_items']])
        sol = "\n".join([si['solution'] for si in item['sub_items']])
    else:
        q_text = item['content']
        sol = item['solution']
    
    # Extract the graph tikzpicture
    graph_match = re.search(r'\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}', q_text, re.DOTALL)
    graph = graph_match.group(0) if graph_match else "Graph not found"
    
    return fR"""
\question[5] Given the graph of the function $f$, find each of the following.
\begin{{multicols}}{{2}}
\centering
{graph}

\columnbreak

\begin{{parts}}
\part $f(0)=$\fillin\\ 
\part $f(-8)=$\fillin\\ 
\part $f(-6)=$\fillin\\ 
\part Find $x$ where $f(x)=0$.\\ \\ $x=$\fillin
\end{{parts}}
\end{{multicols}}

\begin{{solution}}
{sol}
\end{{solution}}
"""

# ==========================================
# 3. EXAM CONFIGURATION (INDEX-BASED)
# ==========================================

# Maps CheckIt Index -> Formatter
EXAM_MAP = {
    0:  {"fmt": format_standard, "note": "Order of Ops"},
    1:  {"fmt": format_standard, "note": "Radical"},
    2:  {"fmt": format_standard, "note": "Exponents"},
    3:  {"fmt": format_standard, "note": "Poly Sub"},
    4:  {"fmt": lambda i: format_standard(i, space=2), "note": "Poly Mult"},
    5:  {"fmt": lambda i: format_standard(i, space=2), "note": "Poly Div"},
    6:  {"fmt": format_standard, "note": "Linear Solve"},
    7:  {"fmt": format_standard, "note": "Fraction Solve"},
    8:  {"fmt": format_standard, "note": "Literal Solve"},
    9:  {"fmt": format_standard, "note": "Word Problem"},
    10: {"fmt": format_q11_graphing, "note": "Linear Graphing"},
    11: {"fmt": format_q12_eval, "note": "Eval Function"},
    12: {"fmt": format_q13_14_combined, "note": "Func/Dom/Range (Double)"}, 
    13: {"fmt": format_q15_reading, "note": "Read Graph"},
    14: {"fmt": format_standard, "note": "Parallel Lines"},
    15: {"fmt": format_standard, "note": "Ranking/Word"},
    16: {"fmt": lambda i: format_standard(i, space=2), "note": "System Solve"},
}

# ==========================================
# 4. MAIN SCRIPT
# ==========================================

def process_exam(checkit_file, template_file, output_file):
    # 1. Parse CheckIt
    with open(checkit_file, 'r') as f:
        checkit_raw = f.read()
        
    items_raw = re.split(r'\\item\s*%%%%% SpaTeXt Commands %%%%%', checkit_raw)[1:]
    parsed_items = [parse_checkit_item(b) for b in items_raw if b.strip()]
    print(f"Parsed {len(parsed_items)} items from CheckIt.")

    # 2. Read Template
    with open(template_file, 'r') as f:
        template_raw = f.read()
    
    if "\\begin{questions}" in template_raw:
        preamble = template_raw.split("\\begin{questions}")[0]
        postamble = template_raw.split("\\end{questions}")[1]
    else:
        print("Error: Could not find \\begin{questions} in template.")
        return

    # 3. Build Exam Content
    exam_content = ""
    
    for idx in range(len(EXAM_MAP)):
        if idx >= len(parsed_items):
            print(f"Warning: Config asks for Item {idx}, but CheckIt only has {len(parsed_items)}.")
            break
            
        config = EXAM_MAP[idx]
        item = parsed_items[idx]
        
        print(f"Processing Item {idx}: {config['note']}")
        exam_content += config['fmt'](item) + "\n"
        
        # Add explicit newpages for formatting (tuned to 14pt layout)
        if idx in [2, 5, 8, 10, 11, 12, 13, 14, 15]: 
            exam_content += "\\newpage\n"

    # 4. Write Output
    full_latex = preamble + "\n\\begin{questions}\n" + exam_content + "\n\\end{questions}\n" + postamble
    
    with open(output_file, 'w') as f:
        f.write(full_latex)
    
    print(f"Generated {output_file}")

if __name__ == "__main__":
    process_exam("main.tex", "0482-WebMidterm14pt.tex", "ReadyToPrint_Midterm.tex")