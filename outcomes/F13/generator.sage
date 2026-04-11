from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Pick radicals to ensure two terms combine and one does not
        # Using standard, clean square-free integers
        rads = [2, 3, 5, 6, 7, 10]
        r1 = choice(rads)
        r2 = choice([r for r in rads if r != r1])
        
        # We will output an expression that evaluates to:
        # a1*y*\sqrt{r1*x} + a2*x*\sqrt{r2*x} + a3*y*\sqrt{r1*x}
        
        while True:
            # Term 1 parameters
            c1 = choice([1, -1])
            d1 = randint(2, 5)
            a1 = c1 * d1
            
            # Term 2 parameters
            c2 = choice([1, -1, 2, -2, 3, -3])
            d2 = randint(2, 4)
            a2 = c2 * d2
            
            # Term 3 parameters
            c3 = choice([1, -1, 2, -2, 3, -3])
            d3 = randint(2, 4)
            a3 = c3 * d3
            
            # Ensure the like-terms don't completely cancel out to 0
            if a1 + a3 != 0 and a2 != 0:
                break

        # Formatting Helper: For the initial unsimplified problem statement
        def problem_term(c, var_out, in_val, in_var, is_first):
            if c > 0:
                prefix = "" if is_first else "+ "
                val = "" if c == 1 else str(c)
            else:
                prefix = "-" if is_first else "- "
                val = "" if c == -1 else str(abs(c))
            return f"{prefix}{val}{var_out}\\sqrt{{{in_val}{in_var}}}"

        # Formatting Helper: For the evaluated and simplified terms
        def simplified_term(c, var_out, r_val, in_var, is_first):
            if c > 0:
                prefix = "" if is_first else "+ "
                val = "" if c == 1 and var_out != "" else str(c)
            else:
                prefix = "-" if is_first else "- "
                val = "" if c == -1 and var_out != "" else str(abs(c))
            return f"{prefix}{val}{var_out}\\sqrt{{{r_val}{in_var}}}"

        # 2. Build the initial problem statement
        p_t1 = problem_term(c1, "", d1**2 * r1, "xy^2", True)
        p_t2 = problem_term(c2, "", d2**2 * r2, "x^3", False)
        p_t3 = problem_term(c3, "y", d3**2 * r1, "x", False)
        problem_latex = f"{p_t1} {p_t2} {p_t3}"
        
        # 3. Build the intermediate extraction step (e.g. 5y\sqrt{6x} - 2x(3)\sqrt{2x} ...)
        t1_ext = f"{d1}y\\sqrt{{{r1}x}}" if c1 == 1 else f"-{d1}y\\sqrt{{{r1}x}}"
        
        prefix_c2 = "+ " if c2 > 0 else "- "
        val_c2 = "" if abs(c2) == 1 else str(abs(c2))
        t2_ext = f"{prefix_c2}{val_c2}x({d2})\\sqrt{{{r2}x}}"
        
        prefix_c3 = "+ " if c3 > 0 else "- "
        val_c3 = "" if abs(c3) == 1 else str(abs(c3))
        t3_ext = f"{prefix_c3}{val_c3}y({d3})\\sqrt{{{r1}x}}"
        
        step1_latex = f"{t1_ext} {t2_ext} {t3_ext}"
        
        # 4. Build the simplified individual terms step
        s_t1 = simplified_term(a1, "y", r1, "x", True)
        s_t2 = simplified_term(a2, "x", r2, "x", False)
        s_t3 = simplified_term(a3, "y", r1, "x", False)
        step2_latex = f"{s_t1} {s_t2} {s_t3}"
        
        # 5. Build the final combined step
        ans_t1 = simplified_term(a1 + a3, "y", r1, "x", True)
        ans_t2 = simplified_term(a2, "x", r2, "x", False)
        
        # Safely wrap the final expression in a LaTeX box here in Python
        ans_latex = f"\\boxed{{{ans_t1} {ans_t2}}}"
        
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"& {problem_latex} \\\\\n"
            f"&= {step1_latex} \\\\\n"
            f"&= {step2_latex} \\\\\n"
            f"&= {ans_latex}\n"
            f"\\end{{aligned}}"
        )

        return {
            "problem_latex": problem_latex,
            "align_solution": align_solution
        }