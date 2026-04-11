from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variables
        v1_str, v2_str = choice([('x', 'y'), ('a', 'b'), ('m', 'n')])
        v1, v2 = var(f"{v1_str} {v2_str}")

        # 2. Pick the index for the fractional exponent (mostly 2, sometimes 3)
        n = choice([2, 2, 2, 3])

        # 3. Build the "clean" denominator first to guarantee perfect simplification
        if n == 2:
            k = randint(2, 10)  # e.g., 9 so that 9^2 = 81
        else:
            k = randint(2, 5)   # Keep cubes reasonably small (e.g., 3^3 = 27)

        # Pick final simplified exponents
        m1 = randint(1, 4)
        m2 = randint(1, 4)

        # 4. Calculate the unsimplified inner parameters
        c = k**n
        e1 = n * m1
        e2 = n * m2

        # 5. Build the problem statement
        inner_expr = c * v1**e1 * v2**e2
        problem_latex = f"\\left({latex(inner_expr)}\\right)^{{-\\frac{{1}}{{{n}}}}}"

        # 6. Format the step-by-step solution mirroring the grading key
        # Step 1: Drop to denominator and apply radical
        if n == 2:
            step1_latex = f"\\frac{{1}}{{\\sqrt{{{latex(inner_expr)}}}}}"
        else:
            step1_latex = f"\\frac{{1}}{{\\sqrt[{n}]{{{latex(inner_expr)}}}}}"

        # Step 2: Final simplified answer
        ans_denom = k * v1**m1 * v2**m2
        
        # Safely wrap the final fraction in a LaTeX box here in Python
        ans_latex = f"\\boxed{{\\frac{{1}}{{{latex(ans_denom)}}}}}"

        # Assemble the aligned solution block
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{problem_latex} &= {step1_latex} \\\\\n"
            f"&= {ans_latex}\n"
            f"\\end{{aligned}}"
        )

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution
        }