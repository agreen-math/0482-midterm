from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Lock variable to x for exam consistency
        v_str = 'x'
        v = var(v_str)

        # 2. Pick integer a and b for the roots a +/- bi
        # This guarantees the discriminant will be a perfect square negative number
        while True:
            a = randint(-6, 6)
            b = randint(1, 6) # Strictly positive to avoid redundant +/- signs
            
            # Ensure there is a linear middle term so they have to use the full formula
            if a != 0: 
                break

        # 3. Calculate coefficients for the expanded polynomial x^2 + Bx + C = 0
        B = -2 * a
        C = a**2 + b**2

        poly = v**2 + B*v + C
        problem_latex = f"{latex(poly)} = 0"

        # 4. Format the step-by-step solution
        # Form: x = (-B \pm \sqrt{B^2 - 4(1)(C)}) / 2(1)
        minus_B = -B
        B_sq = B**2
        four_ac = 4 * 1 * C
        disc = B_sq - four_ac # This will always equal -4b^2

        # Step 1: Plug into formula
        step1_num = f"{minus_B} \\pm \\sqrt{{({B})^2 - 4(1)({C})}}"
        step1_latex = f"{v_str} &= \\frac{{{step1_num}}}{{2(1)}}"

        # Step 2: Simplify arithmetic inside radical
        step2_num = f"{minus_B} \\pm \\sqrt{{{B_sq} - {four_ac}}}"
        step2_latex = f"&= \\frac{{{step2_num}}}{{2}}"

        # Step 3: Show the negative discriminant
        step3_num = f"{minus_B} \\pm \\sqrt{{{disc}}}"
        step3_latex = f"&= \\frac{{{step3_num}}}{{2}}"

        # Step 4: Extract the imaginary unit and perfect square (e.g. \sqrt{-36} -> 6i)
        rad_simplified = f"{2*b}i" if b != 1 else "2i"
        step4_num = f"{minus_B} \\pm {rad_simplified}"
        step4_latex = f"&= \\frac{{{step4_num}}}{{2}}"

        # Step 5: Final simplification (divide both terms by 2)
        ans_str = f"{a} \\pm {b}i" if b != 1 else f"{a} \\pm i"

        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{step1_latex} \\\\\n"
            f"{step2_latex} \\\\\n"
            f"{step3_latex} \\\\\n"
            f"{step4_latex} \\\\\n"
            f"&= {ans_str}\n"
            f"\\end{{aligned}}"
        )

        # 5. Safely wrap the final answer in a LaTeX box here in Python
        ans_latex = f"\\boxed{{{v_str} = {ans_str}}}"

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }