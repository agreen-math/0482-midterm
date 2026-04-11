from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'w', 'a', 'p'])
        v = var(v_str)

        # 2. Lock leading coefficient to 1 for consistent exam difficulty
        # Pick 'b' between 2 and 12 (avoids x^2 - 1 for better visual pattern recognition)
        b = randint(2, 12)

        # 3. Construct the expanded polynomial: v^2 - b^2
        poly = v**2 - b**2

        # 4. Construct the factors
        f1 = v - b
        f2 = v + b
        ans_latex = f"\\left({latex(f1)}\\right)\\left({latex(f2)}\\right)"

        # 5. Format the clean instructor-facing solution block
        step1_latex = f"({v_str})^2 - ({b})^2"

        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{latex(poly)} &= {step1_latex} \\\\\n"
            f"&= \\boxed{{{ans_latex}}}\n"
            f"\\end{{aligned}}"
        )

        return {
            "poly_latex": latex(poly),
            "align_solution": align_solution
        }