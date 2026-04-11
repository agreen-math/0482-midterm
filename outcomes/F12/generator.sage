from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variables to keep it fresh across versions
        v1_str, v2_str = choice([('x', 'y'), ('a', 'b'), ('m', 'n')])
        v1, v2 = var(f"{v1_str} {v2_str}")

        # 2. Pick outer coefficients and exponents
        c_out = randint(2, 9)
        e_out1 = randint(0, 2)
        e_out2 = randint(0, 2)
        
        # Ensure there's at least one variable on the outside to match the 5x layout
        if e_out1 == 0 and e_out2 == 0:
            e_out1 = 1

        # 3. Pick inner coefficients and exponents (perfect squares only!)
        p = randint(2, 12)  # The evaluated root coefficient
        c_in = p**2         # The perfect square inside the radical
        
        k1 = randint(1, 4)  # The evaluated root exponent for v1
        e_in1 = 2 * k1      # The even exponent inside the radical
        
        k2 = randint(1, 4)  # The evaluated root exponent for v2
        e_in2 = 2 * k2      # The even exponent inside the radical

        # 4. Construct expressions
        outer_expr = c_out * v1**e_out1 * v2**e_out2
        inner_expr = c_in * v1**e_in1 * v2**e_in2
        
        problem_latex = f"{latex(outer_expr)} \\sqrt{{{latex(inner_expr)}}}"

        # 5. Format the step-by-step solution
        # Mirror the exact flow of the key: 5x(11)(x)(y^2)
        step1_latex = f"{latex(outer_expr)}({p})"
        if k1 > 0:
            step1_latex += f"({latex(v1**k1)})"
        if k2 > 0:
            step1_latex += f"({latex(v2**k2)})"

        # 6. Final simplified answer
        final_expr = (c_out * p) * v1**(e_out1 + k1) * v2**(e_out2 + k2)
        
        # Safely box the final expression in Python
        ans_latex = f"\\boxed{{{latex(final_expr)}}}"

        # Put it all together for the instructor block
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"& {problem_latex} \\\\\n"
            f"&= {step1_latex} \\\\\n"
            f"&= {ans_latex}\n"
            f"\\end{{aligned}}"
        )

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution
        }