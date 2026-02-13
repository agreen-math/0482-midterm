import re
import sys

# ==========================================
# 1. PARSING LOGIC
# ==========================================

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
    Finds \stxOuttro{...} and extracts the solution text.
    Returns clean solution string.
    """
    sol_match = re.search(r'\\stxOuttro\s*\{', content)
    if not sol_match:
        return ""
    
    sol_content, _ = get_braced_content(content, sol_match.end() - 1)
    # Remove the word "SOLUTION" title if present
    sol_content = re.sub(r'^\s*SOLUTION\s*', '', sol_content, flags=re.IGNORECASE | re.MULTILINE).strip()
    return sol_content

def parse_checkit_item(raw_block):
    """
    Parses a top-level CheckIt item.
    Uses strict Knowl matching to identify sub-items in multi-part questions.
    """
    # 1. Get the main content inside the top-level \stxKnowl
    match = re.search(r'\\stxKnowl\s*\{', raw_block)
    if not match: return None
    outer_content, _ = get_braced_content(raw_block, match.end() - 1)

    # 2. Check for Multi-Part Structure (nested Knowls inside Enumerate)
    # We look specifically for \item followed by \stxKnowl
    sub_knowl_iter = list(re.finditer(r'\\item\s*\\stxKnowl\s*\{', outer_content))
    
    if sub_knowl_iter:
        # --- MULTI-PART ITEM ---
        
        # Text before the first item is the "Intro"
        intro_text = outer_content[:sub_knowl_iter[0].start()].strip()
        # Clean up enumerate start if caught in intro
        intro_text = re.sub(r'\\begin\s*\{enumerate\}', '', intro_text).strip()
        
        sub_items = []
        for m in sub_knowl_iter:
            # Extract content of the inner Knowl
            content, _ = get_braced_content(outer_content, m.end() - 1)
            
            # Extract Solution from this sub-item
            sol = clean_solutions(content)
            
            # Clean Question Content (remove solution block)
            q_parts = re.split(r'\\stxOuttro\s*\{', content)
            q_content = q_parts[0].strip()
            
            sub_items.append({
                'content': q_content, 
                'solution': sol
            })
            
        return {
            'type': 'multi',
            'intro': intro_text,
            'sub_items': sub_items
        }

    else:
        # --- SINGLE ITEM ---
        sol = clean_solutions(outer_content)
        q_parts = re.split(r'\\stxOuttro', outer_content)
        q_text = q_parts[0].strip()
        
        return {
            'type': 'single', 
            'content': q_text, 
            'solution': sol
        }

# ==========================================
# 2. FORMATTING FUNCTIONS
# ==========================================

def latex_norm(text):
    """Normalize CheckIt math delimiters to standard LaTeX."""
    if not text: return ""
    text = text.replace(r"\(", "$").replace(r"\)", "$")
    text = text.replace(r"\[", "$$").replace(r"\]", "$$")
    return text.strip()

def format_standard(item, points=5, space=1):
    if item['type'] == 'multi':
        # Fallback: Flatten multi-part if routed to standard
        q = item['intro'] + "\n" + "\n".join([f"({i+1}) {si['content']}" for i, si in enumerate(item['sub_items'])])
        sol = "\n".join([f"({i+1}) {si['solution']}" for i, si in enumerate(item['sub_items'])])
    else:
        q = item['content']
        sol = item['solution']
    
    return fR"""
\question[{points}] {latex_norm(q)}
\begin{{solution}}
{latex_norm(sol)}
\end{{solution}}
\vspace{{\stretch{{{space}}}}}\answerline
"""

def format_q11_graphing(item):
    """Extracts equation and produces table layout."""
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
    """Format Q12 as Main Question with (a)(b)(c) parts."""
    intro = latex_norm(item.get('intro', "Evaluate:"))
    if item['type'] == 'single': 
        intro = latex_norm(item['content']) # Fallback
    
    sub_items = item.get('sub_items', [])
    if not sub_items and item['type'] == 'single':
        return format_standard(item)

    parts_latex = "\\begin{parts}\n"
    for sub in sub_items:
        q = latex_norm(sub['content'])
        sol = sub['solution']
        
        parts_latex += f"  \\part {q}\n"
        parts_latex += f"  \\begin{{solution}}{sol}\\end{{solution}}\n"
        parts_latex += f"  \\vspace{{\\stretch{{1}}}}\\answerline\n"
    parts_latex += "\\end{parts}"
    
    return fR"""
\question[5] {intro}
{parts_latex}
"""

def format_q13_14_combined(item):
    """
    Outputs the single header for Q13/14, then loops through the items
    to create Q13 and Q14 sequentially on the SAME page.
    """
    if item['type'] != 'multi':
        return r"\question[5] Error: Q13/14 was not parsed as multi-part."
    
    # 1. Output the shared Header ONCE
    output = r"\uplevel{\textbf{For Problems \ref{func-1} and \ref{func-2}, identify the domain and range and determine whether or not the graph represents a function. If it is not a function, explain why.}}" + "\n"
    
    # Loop through items
    for i, sub in enumerate(item['sub_items']):
        graph_code = sub['content']
        sol = sub['solution']
        label = f"func-{i+1}"
        
        output += fR"""
\question[5]\label{{{label}}} \,

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
{graph_code}

\end{{multicols}}

\begin{{solution}}
{sol}
\end{{solution}}
"""
        # Insert vspace between the two questions
        if i < len(item['sub_items']) - 1:
            output += r"\vspace{\stretch{1}}" + "\n\n"

    return output

def format_q15_reading(item):
    """
    Q15: Reading graph values.
    Dynamically extracts the questions from the CheckIt output.
    Supports both enumerate and itemize lists.
    """
    
    # 1. Get Text & Solution
    if item['type'] == 'multi':
        raw_text_list = [si['content'] for si in item['sub_items']]
        sol = "\n".join([si['solution'] for si in item['sub_items']])
        combined_text = " ".join(raw_text_list)
    else:
        combined_text = item['content']
        sol = item['solution']

    # 2. Extract Graph (TikZ)
    graph_match = re.search(r'\\begin\s*\{tikzpicture\}.*?\\end\s*\{tikzpicture\}', combined_text, re.DOTALL)
    graph = graph_match.group(0) if graph_match else "Graph not found"

    # 3. Parse Questions
    questions = []
    list_match = re.search(r'\\begin\{(enumerate|itemize)\}(.*?)\\end\{\1\}', combined_text, re.DOTALL)
    
    if list_match:
        list_body = list_match.group(2)
        items = re.split(r"\\item", list_body)
        for it in items:
            clean_it = it.strip()
            if graph in clean_it:
                clean_it = clean_it.replace(graph, "").strip()
            # Clean CheckIt labels like "(a)", "a)"
            clean_it = re.sub(r'^(\(\w\)|[\w]\)|[\w]\.)\s*', '', clean_it)
            if clean_it:
                questions.append(clean_it)
    else:
        txt = combined_text.replace(graph, "").strip()
        if txt: questions.append(txt)

    # 4. Format Parts
    parts_latex = "\\begin{parts}\n"
    for q in questions:
        q_norm = latex_norm(q)
        
        if "Find" in q_norm or "Solve" in q_norm:
             # CHANGED: Added \vspace{2em} to the line break as requested
             parts_latex += f"  \\part {q_norm} \\\\[2em] $x=$ \\fillin\\vspace{{2em}}\\\\\n"
        else:
             parts_latex += f"  \\part {q_norm} = \\fillin\\vspace{{2em}}\\\\\n"
             
    parts_latex += "\\end{parts}"

    return fR"""
\question[5] Given the graph of the function $f$, find each of the following.
\vspace{{2em}}
\begin{{multicols}}{{2}}
\centering
{graph}

\columnbreak

{parts_latex}
\end{{multicols}}

\begin{{solution}}
{sol}
\end{{solution}}
"""

# ==========================================
# 3. EXAM CONFIGURATION (INDEX MAP)
# ==========================================

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
    11: {"fmt": format_q12_eval, "note": "Eval Function (Parts)"},
    12: {"fmt": format_q13_14_combined, "note": "Func/Dom/Range (Split into 2 Qs)"}, 
    13: {"fmt": format_q15_reading, "note": "Read Graph"},
    14: {"fmt": format_standard, "note": "Parallel Lines"},
    15: {"fmt": format_standard, "note": "Ranking/Word"},
    16: {"fmt": lambda i: format_standard(i, space=2), "note": "System Solve"},
}

# ==========================================
# 4. MAIN PROCESSOR
# ==========================================

def process_exam(checkit_file, template_file, output_file):
    # 1. Parse CheckIt Output
    try:
        with open(checkit_file, 'r') as f:
            checkit_raw = f.read()
    except FileNotFoundError:
        print(f"Error: {checkit_file} not found.")
        return

    # Split into raw items (CheckIt delimiters)
    raw_blocks = re.split(r'\\item\s*%%%%% SpaTeXt Commands %%%%%', checkit_raw)
    if len(raw_blocks) > 0: raw_blocks = raw_blocks[1:]
    
    parsed_items = []
    for block in raw_blocks:
        if '\\stxKnowl' in block:
            item = parse_checkit_item(block)
            if item: parsed_items.append(item)
    
    print(f"Parsed {len(parsed_items)} items from CheckIt.")

    # 2. Read Template
    try:
        with open(template_file, 'r') as f:
            template_raw = f.read()
    except FileNotFoundError:
        print(f"Error: {template_file} not found.")
        return
    
    if "\\begin{questions}" in template_raw:
        preamble = template_raw.split("\\begin{questions}")[0]
        postamble = template_raw.split("\\end{questions}")[1]
    else:
        print("Error: Template is missing \\begin{questions} environment.")
        return

    # 3. Generate Exam Content
    exam_content = ""
    
    for idx in range(len(EXAM_MAP)):
        if idx >= len(parsed_items):
            print(f"Warning: EXAM_MAP asks for item {idx}, but CheckIt only provided {len(parsed_items)} items.")
            break
            
        config = EXAM_MAP[idx]
        item = parsed_items[idx]
        
        print(f"Generating Q{idx+1}: {config['note']}")
        exam_content += config['fmt'](item) + "\n"
        
        # Add newpages based on layout needs
        if idx in [2, 5, 8, 10, 11, 12, 14]: 
            exam_content += "\\newpage\n"

    # 4. Write Output
    full_latex = preamble + "\n\\begin{questions}\n" + exam_content + "\n\\end{questions}\n" + postamble
    
    with open(output_file, 'w') as f:
        f.write(full_latex)
    
    print(f"Success! Exam generated at: {output_file}")

if __name__ == "__main__":
    process_exam("main.tex", "0482-WebMidterm14pt.tex", "ReadyToPrint_Midterm.tex")