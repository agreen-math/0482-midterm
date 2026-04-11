from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'a', 'p'])
        v = var(v_str)

        # 2. Pick roots r1 and r2 so the equation is (v - r1)(v - r2) = 0
        while True:
            r1 = randint(-10, 10)
            r2 = randint(-10, 10)
            
            # Ensure solutions are non-zero and distinct for a standard experience
            if r1 == 0 or r2 == 0 or r1 == r2:
                continue
                
            # Values for the expanded trinomial v^2 + bv + c = 0
            # b = -(r1 + r2), c = r1 * r2
            b_val = -(r1 + r2)
            c_val = r1 * r2
            
            # Constraint: Keep the factor table readable (max 8 divisors for c)
            if len(divisors(abs(c_val))) > 8:
                continue
                
            break

        # 3. Construct the equation string
        poly = v**2 + b_val*v + c_val
        equation_latex = f"{latex(poly)} = 0"

        # 4. Build the Factor Table for grading
        c_abs = abs(c_val)
        divs = divisors(c_abs)
        factor_pairs = []
        for d in divs:
            d2 = c_abs // d
            if d > d2: continue
            if c_val > 0:
                factor_pairs.append((d, d2)); factor_pairs.append((-d, -d2))
            else:
                factor_pairs.append((d, -d2))
                if d != d2: factor_pairs.append((-d, d2))
        
        factor_pairs.sort(key=lambda x: (abs(x[0]), x[0]))
        table_rows = ""
        for f1, f2 in factor_pairs:
            pair_sum = f1 + f2
            if pair_sum == b_val:
                table_rows += f"\\mathbf{{{f1}, {f2}}} & \\mathbf{{{pair_sum}}} \\\\\n"
            else:
                table_rows += f"{f1}, {f2} & {pair_sum} \\\\\n"

        # 5. Final factored form and solutions
        # Factors are (v + f1)(v + f2) where f1+f2 = b_val
        p, q = -r1, -r2
        ans_latex = f"\\left({latex(v + p)}\\right)\\left({latex(v + q)}\\right) = 0"
        
        # Safely wrap the final solutions in a LaTeX box here in Python
        solutions_latex = f"\\boxed{{{v_str} = {r1}, {r2}}}"

        return {
            "equation_latex": equation_latex,
            "factor_table": f"\\begin{{array}}{{|c|c|}} \\hline \\text{{Factors of }} {c_val} & \\text{{Sum}} \\\\ \\hline {table_rows} \\hline \\end{{array}}",
            "ans_latex": ans_latex,
            "solutions_latex": solutions_latex
        }