from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Select base values to guarantee clean, one-step radical simplification
        # r is the shared root that will simplify out of the first term
        r = choice([2, 3, 5]) 
        # m is the leftover root that will remain in the second term
        m = choice([x for x in [2, 3, 5] if x != r])
        # k is the inner radical of the second term
        k = r * m 

        # 2. Select Coefficients
        a = randint(2, 5)     # Outer coefficient
        c = choice([1, 1, 2, 3]) # Inner term 1 coefficient (weighted toward 1)
        b = choice([-5, -4, -3, -2, 2, 3, 4, 5]) # Inner term 2 coefficient

        # 3. Build the Problem Statement
        outer = f"{a}\\sqrt{{{r}}}"
        term1_in = f"\\sqrt{{{r}}}" if c == 1 else f"{c}\\sqrt{{{r}}}"
        
        sign_b_in = "+" if b > 0 else "-"
        term2_in = f"{sign_b_in} {abs(b)}\\sqrt{{{k}}}"

        problem_latex = f"{outer}({term1_in} {term2_in})"

        # 4. Format the step-by-step solution
        ab_coeff = a * b
        ac_coeff = a * c
        sign_ab = "+" if ab_coeff > 0 else "-"

        # Step 1: Distribute (e.g. 2\sqrt{2 \cdot 2} - 6\sqrt{2 \cdot 6})
        step1_t1 = f"{ac_coeff}\\sqrt{{{r} \\cdot {r}}}"
        step1_t2 = f"{sign_ab} {abs(ab_coeff)}\\sqrt{{{r} \\cdot {k}}}"
        step1_latex = f"{step1_t1} {step1_t2}"

        # Step 2: Multiply inside radicals (e.g. 2(2) - 6\sqrt{12})
        step2_t1 = f"{ac_coeff}({r})"
        step2_t2 = f"{sign_ab} {abs(ab_coeff)}\\sqrt{{{r * k}}}"
        step2_latex = f"{step2_t1} {step2_t2}"

        # Step 3: Extract perfect squares (e.g. 4 - 6(2\sqrt{3}))
        step3_t1 = f"{ac_coeff * r}"
        step3_t2 = f"{sign_ab} {abs(ab_coeff)}({r}\\sqrt{{{m}}})"
        step3_latex = f"{step3_t1} {step3_t2}"

        # 5. Build the final boxed answer
        ans_t1 = f"{ac_coeff * r}"
        ans_coeff2 = ab_coeff * r
        ans_sign = "+" if ans_coeff2 > 0 else "-"
        ans_t2 = f"{ans_sign} {abs(ans_coeff2)}\\sqrt{{{m}}}"

        ans_latex = f"\\boxed{{{ans_t1} {ans_t2}}}"

        # Assemble the aligned solution block
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"& {problem_latex} \\\\\n"
            f"&= {step1_latex} \\\\\n"
            f"&= {step2_latex} \\\\\n"
            f"&= {step3_latex} \\\\\n"
            f"&= {ans_latex}\n"
            f"\\end{{aligned}}"
        )

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution
        }