from sage.all import *
from random import randint, choice
import math

class Generator(BaseGenerator):
    def data(self):
        # 1. Choose a variable set to keep things visually interesting
        vars_choice = choice([('a', 'b', 'c'), ('x', 'y', 'z'), ('m', 'n', 'p')])
        v1, v2, v3 = vars_choice

        # 2. Generate Coefficients
        # Pick a target GCF for the coefficients
        gcf_coeff = choice([2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20])
        
        # Pick three multipliers that share NO common factors among all three
        while True:
            m1 = randint(1, 6)
            m2 = randint(1, 6)
            m3 = randint(1, 6)
            
            # Avoid all three terms being exactly the same
            if m1 == m2 == m3:
                continue
                
            # Ensure the overall GCF of the multipliers is strictly 1
            if math.gcd(m1, math.gcd(m2, m3)) == 1:
                break
                
        c1 = gcf_coeff * m1
        c2 = gcf_coeff * m2
        c3 = gcf_coeff * m3
        
        # 3. Generate Exponents (Ensuring every term has at least 1 of each variable)
        e11, e12, e13 = randint(1, 8), randint(1, 8), randint(1, 8)
        e21, e22, e23 = randint(1, 8), randint(1, 8), randint(1, 8)
        e31, e32, e33 = randint(1, 8), randint(1, 8), randint(1, 8)
        
        # Calculate the GCF exponents (the minimum exponent for each variable)
        g_e1 = min(e11, e21, e31)
        g_e2 = min(e12, e22, e32)
        g_e3 = min(e13, e23, e33)
        
        # 4. Term Formatting Helper
        def format_term(c, exp1, exp2, exp3):
            term = str(c)
            
            if exp1 == 1: term += f"{v1}"
            elif exp1 > 1: term += f"{v1}^{{{exp1}}}"
            
            if exp2 == 1: term += f"{v2}"
            elif exp2 > 1: term += f"{v2}^{{{exp2}}}"
            
            if exp3 == 1: term += f"{v3}"
            elif exp3 > 1: term += f"{v3}^{{{exp3}}}"
            
            return term
            
        term1 = format_term(c1, e11, e12, e13)
        term2 = format_term(c2, e21, e22, e23)
        term3 = format_term(c3, e31, e32, e33)
        ans_term = format_term(gcf_coeff, g_e1, g_e2, g_e3)
        
        # --- Solution Formatting (Instructor Facing) ---
        c1_fact = latex(factor(c1))
        c2_fact = latex(factor(c2))
        c3_fact = latex(factor(c3))
        
        # Cleanly check for primes to avoid printing "3 = 3"
        if is_prime(gcf_coeff): 
            gcf_line = f"{gcf_coeff}"
        else:
            gcf_line = f"{latex(factor(gcf_coeff))} = {gcf_coeff}"
            
        align_coeffs = (
            f"\\begin{{aligned}}\n"
            f"{c1} &= {c1_fact} \\\\\n"
            f"{c2} &= {c2_fact} \\\\\n"
            f"{c3} &= {c3_fact} \\\\\n"
            f"\\text{{GCF}} &= {gcf_line}\n"
            f"\\end{{aligned}}"
        )
        
        align_vars = (
            f"\\begin{{aligned}}\n"
            f"\\text{{Exp. of }} {v1} &: \\min({e11}, {e21}, {e31}) = {g_e1} \\\\\n"
            f"\\text{{Exp. of }} {v2} &: \\min({e12}, {e22}, {e32}) = {g_e2} \\\\\n"
            f"\\text{{Exp. of }} {v3} &: \\min({e13}, {e23}, {e33}) = {g_e3}\n"
            f"\\end{{aligned}}"
        )
        
        # Safely wrap the answer in a LaTeX box here in Python
        ans_latex = f"\\boxed{{{ans_term}}}"
        
        return {
            "term1": term1,
            "term2": term2,
            "term3": term3,
            "ans_latex": ans_latex,
            "align_coeffs": align_coeffs,
            "align_vars": align_vars
        }