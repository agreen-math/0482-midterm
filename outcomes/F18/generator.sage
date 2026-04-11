from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable
        v_str = choice(['x', 'y', 'm', 'n', 'w', 'p'])
        v = var(v_str)

        # 2. Build the problem backward to guarantee a clean integer solution
        # and avoid any extraneous solutions or fractions.
        ans_val = randint(-10, 10)  # The final integer answer
        
        while True:
            a = choice([-5, -4, -3, -2, 2, 3, 4, 5]) # Coefficient of x
            c = randint(2, 12) # The isolated constant on the right side
            
            # We need a*ans_val + b = c^2, so b = c^2 - a*ans_val
            b = c**2 - a * ans_val
            
            # Keep the expression looking like a standard binomial (avoid b=0)
            if b != 0:
                break

        # 3. Build the expressions
        inner_expr = a*v + b
        problem_latex = f"\\sqrt{{{latex(inner_expr)}}} = {c}"

        # 4. Format the step-by-step solution
        c_squared = c**2
        rhs_step2 = c_squared - b
        
        # Step 1: Square both sides
        step1_latex = f"{latex(inner_expr)} &= {c_squared}"
        
        # Step 2: Isolate the variable term
        step2_latex = f"{latex(a*v)} &= {rhs_step2}"
        
        # Step 3: Final answer
        step3_latex = f"{v_str} &= {ans_val}"

        align_solution = (
            f"\\begin{{aligned}}\n"
            f"\\sqrt{{{latex(inner_expr)}}} &= {c} \\\\\n"
            f"{step1_latex} \\\\\n"
            f"{step2_latex} \\\\\n"
            f"{step3_latex}\n"
            f"\\end{{aligned}}"
        )

        # 5. Safely wrap the final answer in a LaTeX box in Python
        ans_latex = f"\\boxed{{{v_str} = {ans_val}}}"

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }