from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Lock variable to x for exam consistency
        v_str = 'x'
        v = var(v_str)

        # 2. Pick parameters to ensure a fractional linear solution
        while True:
            # We build the equation (ax+b)/(cx+d) = (ex)/(x+g)
            # To make the quadratics cancel, we need a = e*c
            e = choice([2, 3, 4, 5])
            c = choice([2, 3, 4, 5])
            a = e * c
            
            # Non-zero constants for the rest of the terms
            b = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            d = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            g = choice([-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7])
            
            L1 = a*g + b
            L2 = e*d
            
            # Prevent x terms from cancelling out completely (which would leave no solution)
            if L1 == L2: 
                continue
            
            c_val = b * g
            x_val = L2 - L1
            
            # Check for fractional (non-integer) solution
            if c_val % x_val == 0: 
                continue
            
            # Convert to a true fraction for checking domain restrictions
            sol = QQ(c_val) / QQ(x_val)
            
            # Prevent extraneous solutions (where denominator would be 0)
            if sol == QQ(-d)/QQ(c) or sol == QQ(-g)/QQ(1):
                continue
                
            # Ensure the fractions in the original equation don't simplify trivially
            if a*d == b*c:
                continue
                
            break

        # 3. Construct original equation
        num1 = a*v + b
        den1 = c*v + d
        num2 = e*v
        den2 = v + g
        
        eq_latex = f"\\frac{{{latex(num1)}}}{{{latex(den1)}}} = \\frac{{{latex(num2)}}}{{{latex(den2)}}}"

        # 4. Helper for term formatting in the expanded FOIL step
        def term(coeff, var_str=""):
            if coeff == 0: return ""
            if coeff == 1 and var_str: return f"+ {var_str}"
            if coeff == -1 and var_str: return f"- {var_str}"
            if coeff > 0: return f"+ {coeff}{var_str}"
            return f"- {abs(coeff)}{var_str}"

        # 5. Format the step-by-step solution
        # Step 1: Cross multiply
        step1_latex = f"\\left({latex(num1)}\\right)\\left({latex(den2)}\\right) &= {latex(num2)}\\left({latex(den1)}\\right)"
        
        # Step 2: Expand FOIL
        term1 = f"{a}x^2"
        term2 = term(a*g, "x")
        term3 = term(b, "x")
        term4 = term(b*g)
        step2_L = f"{term1} {term2} {term3} {term4}"
        
        term_R1 = f"{e*c}x^2"
        term_R2 = term(e*d, "x")
        step2_R = f"{term_R1} {term_R2}"
        step2_latex = f"{step2_L} &= {step2_R}"
        
        # Step 3: Combine and cancel quadratic
        step3_L = latex(L1*v + c_val)
        step3_R = latex(L2*v)
        step3_latex = f"{step3_L} &= {step3_R}"
        
        # Step 4: Isolate x
        step4_latex = f"{c_val} &= {latex(x_val*v)}"
        
        align_solution = (
            f"\\begin{{aligned}}\n"
            f"{step1_latex} \\\\\n"
            f"{step2_latex} \\\\\n"
            f"{step3_latex} \\\\\n"
            f"{step4_latex}\n"
            f"\\end{{aligned}}"
        )
        
        ans_latex = f"\\boxed{{x = {latex(sol)}}}"

        return {
            "eq_latex": eq_latex,
            "align_solution": align_solution,
            "ans_latex": ans_latex
        }