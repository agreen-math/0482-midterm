from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Lock variable to x for exam consistency
        v_str = 'x'
        v = var(v_str)

        while True:
            # 2. Pick the FINAL integer solutions first (e.g., 5, -2)
            r1 = randint(-10, 10)
            r2 = randint(-10, 10)
            
            # Ensure distinct, non-zero roots for standard difficulty
            if r1 == r2 or r1 == 0 or r2 == 0:
                continue

            # The final factors will be (x + f1)(x + f2) = 0
            f1 = -r1
            f2 = -r2

            # Sum and product of the final factors
            S = f1 + f2
            P_final = f1 * f2

            # 3. Build the "Trap" initial factors (x + i1)(x + i2) = k
            # We need i1 + i2 to equal S, but i1*i2 must NOT equal P_final 
            # so that k is a non-zero constant.
            i1 = randint(-12, 12)
            i2 = S - i1

            # Prevent trivial cases or using the exact same binomials
            if i1 == f1 or i1 == f2: 
                continue
            if i1 == 0 or i2 == 0: 
                continue

            P_init = i1 * i2
            k = P_init - P_final

            if k == 0:
                continue

            break

        # 4. Construct expressions
        bin1 = v + i1
        bin2 = v + i2
        problem_latex = f"\\left({latex(bin1)}\\right)\\left({latex(bin2)}\\right) = {k}"

        # 5. Format the step-by-step solution
        # Helper to format FOIL terms cleanly
        def term(coeff, var_s=""):
            if coeff == 0: return ""
            if coeff == 1 and var_s: return f"+ {var_s}"
            if coeff == -1 and var_s: return f"- {var_s}"
            if coeff > 0: return f"+ {coeff}{var_s}"
            return f"- {abs(coeff)}{var_s}"

        # Step 1: Expand FOIL (uncombined)
        foil_outer = term(i2, v_str)
        foil_inner = term(i1, v_str)
        foil_last = term(i1 * i2)
        foil_step_latex = f"{v_str}^2 {foil_outer} {foil_inner} {foil_last} &= {k}"

        # Step 2: Combine like terms
        poly_init = expand(bin1 * bin2)
        step2_latex = f"{latex(poly_init)} &= {k}"

        # Step 3: Set to zero
        poly_final = poly_init - k
        step3_latex = f"{latex(poly_final)} &= 0"

        # Step 4: Re-factor correctly
        factored_final = f"\\left({latex(v + f1)}\\right)\\left({latex(v + f2)}\\right)"
        step4_latex = f"{factored_final} &= 0"

        # Compile aligned solution
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"\\left({latex(bin1)}\\right)\\left({latex(bin2)}\\right) &= {k} \\\\\n"
            f"{foil_step_latex} \\\\\n"
            f"{step2_latex} \\\\\n"
            f"{step3_latex} \\\\\n"
            f"{step4_latex}\n"
            f"\\end{{aligned}}"
        )

        # 6. Safely wrap the final solutions in a LaTeX box here in Python
        ans_latex = f"\\boxed{{x = {r1}, {r2}}}"

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }