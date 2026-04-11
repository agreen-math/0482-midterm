from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Lock variable to x for exam consistency
        v_str = 'x'
        v = var(v_str)

        # 2. Pick one positive and one negative integer root
        while True:
            r1 = randint(1, 10)     # Positive root
            r2 = randint(-10, -1)   # Negative root
            
            # Prevent r1 and r2 from being pure opposites so the middle term doesn't vanish
            if r1 != abs(r2):
                break

        roots_str = f"{r1}, {r2}"

        # 3. Construct the factors
        # If r = 4, factor is (x - 4). If r = -3, factor is (x + 3)
        f1 = v - r1
        f2 = v - r2

        # 4. Construct the intermediate FOIL step to match the grading key
        v2_term = f"{v_str}^2"
        
        # Outer term
        outer_coeff = -r2
        if outer_coeff == 1:
            outer_term = f"+ {v_str}"
        elif outer_coeff == -1:
            outer_term = f"- {v_str}"
        elif outer_coeff > 0:
            outer_term = f"+ {outer_coeff}{v_str}"
        else:
            outer_term = f"- {abs(outer_coeff)}{v_str}"

        # Inner term
        inner_coeff = -r1
        if inner_coeff == 1:
            inner_term = f"+ {v_str}"
        elif inner_coeff == -1:
            inner_term = f"- {v_str}"
        elif inner_coeff > 0:
            inner_term = f"+ {inner_coeff}{v_str}"
        else:
            inner_term = f"- {abs(inner_coeff)}{v_str}"

        # Last term
        last_val = r1 * r2
        last_term = f"- {abs(last_val)}" # r1*r2 will always be negative since signs are mixed
        
        foil_step = f"{v2_term} {outer_term} {inner_term} {last_term}"

        # 5. Construct the final expanded polynomial
        poly = expand(f1 * f2)

        # 6. Format the step-by-step solution
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"\\left({latex(f1)}\\right)\\left({latex(f2)}\\right) &= 0 \\\\\n"
            f"{foil_step} &= 0 \\\\\n"
            f"{latex(poly)} &= 0\n"
            f"\\end{{aligned}}"
        )
        
        # Safely wrap the final expanded equation in a LaTeX box here in Python
        ans_latex = f"\\boxed{{{latex(poly)} = 0}}"

        return {
            "roots_str": roots_str,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }