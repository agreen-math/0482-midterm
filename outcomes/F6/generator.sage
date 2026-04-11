from sage.all import *
from random import randint, choice
import math

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'w', 'p'])
        v = var(v_str)

        # 2. Pick binomial factors (a1*v + b1)(a2*v + b2)
        while True:
            # Leading coefficients
            a1 = randint(1, 4)
            a2 = randint(1, 4)
            # Ensure a = a1*a2 > 1
            if a1 == 1 and a2 == 1:
                continue
                
            # Constant terms
            b1 = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            b2 = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            
            # Ensure the individual binomials can't be factored further
            if math.gcd(a1, abs(b1)) != 1 or math.gcd(a2, abs(b2)) != 1:
                continue
                
            a = a1 * a2
            b = a1 * b2 + a2 * b1
            c = b1 * b2
            
            # Ensure the overall trinomial has NO greatest common factor
            if math.gcd(a, math.gcd(abs(b), abs(c))) != 1:
                continue
                
            # Cap the number of divisors of 'ac' to keep the grading table short
            ac = a * c
            if len(divisors(abs(ac))) > 8:
                continue
                
            break

        # 3. Construct the expanded polynomial
        poly = a*v**2 + b*v + c

        # 4. Build the complete Factor Table for 'ac'
        ac_abs = abs(ac)
        divs = divisors(ac_abs)
        factor_pairs = []
        
        for d in divs:
            d2 = ac_abs // d
            if d > d2: continue # Prevent duplicates
            
            if ac > 0:
                factor_pairs.append((d, d2))
                factor_pairs.append((-d, -d2))
            else:
                factor_pairs.append((d, -d2))
                if d != d2:
                    factor_pairs.append((-d, d2))
                    
        # Sort by the first factor to logically order the table
        factor_pairs.sort(key=lambda x: (abs(x[0]), x[0]))

        table_rows = ""
        for f1_val, f2_val in factor_pairs:
            pair_sum = f1_val + f2_val
            # Bold the correct row so the instructor can spot it instantly
            if pair_sum == b:
                table_rows += f"\\mathbf{{{f1_val}, {f2_val}}} & \\mathbf{{{pair_sum}}} \\\\\n"
            else:
                table_rows += f"{f1_val}, {f2_val} & {pair_sum} \\\\\n"
                
        factor_table = (
            f"\\begin{{array}}{{|c|c|}}\n"
            f"\\hline\n"
            f"\\text{{Factors of }} ac = {ac} & \\text{{Sum}} \\\\\n"
            f"\\hline\n"
            f"{table_rows}"
            f"\\hline\n"
            f"\\end{{array}}"
        )

        # 5. Format the step-by-step grouping solution
        p = a1 * b2
        q = a2 * b1
        
        p_str = f"+ {p}" if p > 0 else f"- {abs(p)}"
        q_str = f"+ {q}" if q > 0 else f"- {abs(q)}"
        c_str = f"+ {c}" if c > 0 else f"- {abs(c)}"
        
        # Step 1: Split the middle term
        step1_latex = f"{a}{v_str}^2 {p_str}{v_str} {q_str}{v_str} {c_str}"
        
        # Step 2: Factor out GCFs from each group
        # First group: a1*a2*v^2 + a1*b2*v = a1*v(a2*v + b2)
        g1_str = f"{v_str}" if a1 == 1 else f"{a1}{v_str}"
        
        # Second group: a2*b1*v + b1*b2 = b1(a2*v + b2)
        g2_sign = "+" if b1 > 0 else "-"
        g2_str = f"{g2_sign} {abs(b1)}"
        
        rem_f = a2*v + b2
        step2_latex = f"{g1_str}\\left({latex(rem_f)}\\right) {g2_str}\\left({latex(rem_f)}\\right)"
        
        # Step 3: Final factored form
        f1 = a1*v + b1
        f2 = a2*v + b2
        ans_latex = f"\\left({latex(f1)}\\right)\\left({latex(f2)}\\right)"
        
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{latex(poly)} &= {step1_latex} \\\\\n"
            f"&= {step2_latex} \\\\\n"
            f"&= \\boxed{{{ans_latex}}}\n"
            f"\\end{{aligned}}"
        )

        return {
            "poly_latex": latex(poly),
            "factor_table": factor_table,
            "align_solution": align_solution
        }