from sage.all import *
from random import randint

class Generator(BaseGenerator):
    def data(self):
        # 1. Define variables
        x, h = var('x h')

        # 2. Pick a random constant 'c' for f(x) = x^2 - c
        # (Using a positive integer so it strictly matches the x^2 - c format)
        c = randint(1, 15)
        
        func_latex = f"x^2 - {c}"

        # 3. Format the step-by-step solution strings
        # Step 1: Substitute (x+h)
        step1 = f"(x+h)^2 - {c}"
        
        # Step 2: Expand the binomial
        step2 = f"x^2 + 2xh + h^2 - {c}"
        
        # Step 3: Set up the full difference quotient numerator
        step3_num = f"(x^2 + 2xh + h^2 - {c}) - (x^2 - {c})"
        
        # Step 4: Cancel terms (the x^2 and the c drop out)
        step4_num = f"2xh + h^2"
        
        # Step 5: Factor out the h
        step5_num = f"h(2x + h)"
        
        # Final simplified answer
        ans = f"2x + h"
        
        # 4. Construct the aligned solution block
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"f(x+h) &= {step1} \\\\\n"
            f"&= {step2} \\\\\n"
            f"\\frac{{f(x+h) - f(x)}}{{h}} &= \\frac{{{step3_num}}}{{h}} \\\\\n"
            f"&= \\frac{{{step4_num}}}{{h}} \\\\\n"
            f"&= \\frac{{{step5_num}}}{{h}} \\\\\n"
            f"&= \\boxed{{{ans}}}\n"
            f"\\end{{aligned}}"
        )

        return {
            "func_latex": func_latex,
            "align_solution": align_solution
        }