from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'w', 'p'])
        
        # 2. Pick a clean target value for the isolated radical (e.g., 6 so that x = 36)
        c = randint(2, 12)
        ans_val = c**2

        # 3. Pick the constant 'a' to add or subtract from the radical side
        a = randint(1, 15)

        # 4. Determine if it's an addition or subtraction problem
        is_addition = choice([True, False])

        if is_addition:
            # \sqrt{v} + a = b  =>  b = c + a
            b = c + a
            op_str = "+"
        else:
            # \sqrt{v} - a = b  =>  b = c - a
            b = c - a
            op_str = "-"

        # 5. Build the problem statement
        problem_latex = f"\\sqrt{{{v_str}}} {op_str} {a} = {b}"

        # 6. Format the step-by-step aligned solution
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"\\sqrt{{{v_str}}} {op_str} {a} &= {b} \\\\\n"
            f"\\sqrt{{{v_str}}} &= {c} \\\\\n"
            f"{v_str} &= {ans_val}\n"
            f"\\end{{aligned}}"
        )

        # 7. Safely wrap the final answer in a LaTeX box in Python
        ans_latex = f"\\boxed{{{v_str} = {ans_val}}}"

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }