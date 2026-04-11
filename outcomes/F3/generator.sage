from sage.all import *
from random import randint, choice
import math

class Generator(BaseGenerator):
    def data(self):
        # 1. Randomize the variable to keep the bank fresh
        v_str = choice(['x', 'y', 'a', 'm', 'n', 'w'])
        v = var(v_str)

        # 2. Pick parameters for (av + b)(cv^2 + d)
        while True:
            a = randint(1, 5)
            b = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            # Ensure no common factors in the first binomial
            if math.gcd(a, abs(b)) != 1: 
                continue

            c = randint(1, 4)
            d = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            # Ensure no common factors in the second binomial
            if math.gcd(c, abs(d)) != 1: 
                continue

            # Ensure (cv^2 + d) is not a difference of squares to prevent needing a second factoring step
            if d < 0:
                if math.isqrt(c)**2 == c and math.isqrt(abs(d))**2 == abs(d):
                    continue

            break

        # 3. Construct factors and the expanded polynomial
        f1 = a*v + b
        f2 = c*v**2 + d
        poly = expand(f1 * f2)

        # 4. Format the grouping steps explicitly to match instructional methods
        # Create the GCF for the first group (e.g., "x^2" or "3x^2")
        gcf1_str = f"{v_str}^2" if c == 1 else f"{c}{v_str}^2"
        
        # Create the GCF for the second group (e.g., "+ 3" or "- 1")
        # Explicitly writing the "1" helps students see the invisible factor
        gcf2_sign = "+" if d > 0 else "-"
        gcf2_val = abs(d)

        # Step 1: x^2(2x+3) + 1(2x+3)
        step1_latex = f"{gcf1_str}\\left({latex(f1)}\\right) {gcf2_sign} {gcf2_val}\\left({latex(f1)}\\right)"
        
        # Step 2: (2x+3)(x^2+1)
        ans_latex = f"\\left({latex(f1)}\\right)\\left({latex(f2)}\\right)"

        # 5. Format the clean instructor-facing solution block
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