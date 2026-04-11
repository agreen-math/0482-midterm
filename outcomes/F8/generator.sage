from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'w', 'p'])
        v = var(v_str)

        # 2. Pick parameters for cv(v^2 - b^2) = 0
        # To provide variety but avoid fractions, c is an integer > 1
        c = choice([2, 3, 4, 5, 6, 8, 10]) 
        b = randint(2, 10) 

        # 3. Construct the expanded polynomial
        poly = c * v**3 - c * b**2 * v
        equation_latex = f"{latex(poly)} = 0"

        # 4. Construct the factors
        gcf_term = c * v
        inside_dos = v**2 - b**2
        f1 = v - b
        f2 = v + b

        step1_latex = f"{latex(gcf_term)}\\left({latex(inside_dos)}\\right) &= 0"
        step2_latex = f"{latex(gcf_term)}\\left({latex(f1)}\\right)\\left({latex(f2)}\\right) &= 0"

        # Format the step-by-step solution
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{latex(poly)} &= 0 \\\\\n"
            f"{step1_latex} \\\\\n"
            f"{step2_latex}\n"
            f"\\end{{aligned}}"
        )
        
        # Safely wrap the final solutions in a LaTeX box here in Python
        # Representing as 0, \pm b for a clean, professional look to match the key
        solutions_latex = f"\\boxed{{{v_str} = 0, \\pm {b}}}"

        return {
            "equation_latex": equation_latex,
            "align_solution": align_solution,
            "solutions_latex": solutions_latex
        }