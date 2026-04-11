from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'a', 'p'])
        v = var(v_str)

        # 2. Pick factors p and q for (v + p)(v + q)
        while True:
            p = randint(-10, 10)
            q = randint(-10, 10)
            
            # Avoid 0 to keep it a full trinomial
            if p == 0 or q == 0:
                continue
                
            # Avoid p = -q to prevent it turning into a difference of squares (x^2 - c)
            if p == -q:
                continue
                
            # Limit the number of divisors to prevent massive grading tables
            # Capping at 8 divisors keeps the table to a maximum of 8 rows
            c_val = p * q
            if len(divisors(abs(c_val))) > 8:
                continue
                
            break

        # 3. Construct the expanded polynomial: v^2 + bv + c
        b = p + q
        c = p * q
        poly = v**2 + b*v + c

        # 4. Construct the factors
        f1 = v + p
        f2 = v + q
        ans_latex = f"\\boxed{{\\left({latex(f1)}\\right)\\left({latex(f2)}\\right)}}"

        # 5. Build the complete Factor Table for grading diagnostics
        c_abs = abs(c)
        divs = divisors(c_abs)
        factor_pairs = []
        
        # Mathematically generate all factor pairs based on the sign of c
        for d in divs:
            d2 = c_abs // d
            if d > d2: continue # Prevent duplicates
            
            if c > 0:
                factor_pairs.append((d, d2))
                factor_pairs.append((-d, -d2))
            else:
                factor_pairs.append((d, -d2))
                if d != d2:
                    factor_pairs.append((-d, d2))
                    
        # Sort by the first factor to make the table logically ordered
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
            f"\\text{{Factors of }} {c} & \\text{{Sum}} \\\\\n"
            f"\\hline\n"
            f"{table_rows}"
            f"\\hline\n"
            f"\\end{{array}}"
        )

        return {
            "poly_latex": latex(poly),
            "factor_table": factor_table,
            "ans_latex": ans_latex
        }