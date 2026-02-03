from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # 1. Outer Exponent (Negative)
        # Typically -2, -3, maybe -4
        exp_out = randint(-4, -2)
        
        # 2. Coefficient (Negative numerator)
        # -2 to -5
        coeff = randint(-5, -2)
        
        # 3. Inner Exponents
        # We need 6 exponents (3 for num, 3 for den). Range -5 to 5.
        exps = [randint(-5, 5) for _ in range(6)]
        
        # Force exactly one random exponent to be 0 to match the "b^0" requirement
        zero_idx = randint(0, 5)
        exps[zero_idx] = 0
        
        # Assign: Numerator (na, nb, nc), Denominator (da, db, dc)
        na, nb, nc = exps[0], exps[1], exps[2]
        da, db, dc = exps[3], exps[4], exps[5]
        
        # Safety: Ensure no variable completely cancels out (e.g. a^3 / a^3)
        # because that removes a variable from the problem.
        while (na - da == 0) or (nb - db == 0) or (nc - dc == 0):
            exps = [randint(-5, 5) for _ in range(6)]
            exps[randint(0, 5)] = 0
            na, nb, nc = exps[0], exps[1], exps[2]
            da, db, dc = exps[3], exps[4], exps[5]

        # --- Logic for Solution Steps ---
        
        # Step 1: Quotient Rule (Subtract bottom from top)
        diff_a = na - da
        diff_b = nb - db
        diff_c = nc - dc
        
        # Step 2: Power Rule (Multiply by outer exponent)
        final_pow_a = diff_a * exp_out
        final_pow_b = diff_b * exp_out
        final_pow_c = diff_c * exp_out
        
        # Step 3: Coefficient Rule
        # coeff^exp_out = 1 / coeff^(-exp_out)
        # Since exp_out is negative, let pos_exp_out = -exp_out
        pos_exp_out = -exp_out
        coeff_denom_val = coeff ** pos_exp_out
        # e.g., (-2)^3 = -8. (-2)^2 = 4.
        
        # --- Formatting Final Answer ---
        
        final_num_parts = []
        final_den_parts = []
        
        # Helper to sort variables to top or bottom
        def sort_var(var_char, power):
            if power > 0:
                final_num_parts.append(f"{var_char}^{{{power}}}")
            elif power < 0:
                final_den_parts.append(f"{var_char}^{{{-power}}}")
            # if power == 0, it disappears (becomes 1)
            
        sort_var("a", final_pow_a)
        sort_var("b", final_pow_b)
        sort_var("c", final_pow_c)
        
        # Construct Numerator String
        if not final_num_parts:
            num_str = "1"
        else:
            num_str = "".join(final_num_parts)
            
        # Construct Denominator String
        # Combine coefficient and variables
        coeff_val = abs(coeff_denom_val)
        vars_str = "".join(final_den_parts)
        den_str = f"{coeff_val}{vars_str}"
        
        # Determine Sign of the fraction
        # If coeff_denom_val is negative (e.g. (-2)^3 = -8), put sign out front
        sign_str = "-" if coeff_denom_val < 0 else ""
        
        final_res = f"{sign_str} \\frac{{{num_str}}}{{{den_str}}}"
        
        # --- Formatting Problem Statement ---
        # Explicitly formatted to ensure ^0 appears (e.g. b^0)
        
        def fmt_exp(val):
            return f"^{{{val}}}"
            
        prob_num = f"{coeff} a{fmt_exp(na)} b{fmt_exp(nb)} c{fmt_exp(nc)}"
        prob_den = f"a{fmt_exp(da)} b{fmt_exp(db)} c{fmt_exp(dc)}"
        
        # Intermediate Step Strings
        # Step 1: Simplify inside
        step1 = f"\\left( {coeff} a^{{{diff_a}}} b^{{{diff_b}}} c^{{{diff_c}}} \\right)^{{{exp_out}}}"
        
        # Step 2: Apply outer exponent
        step2_coeff = f"({coeff})^{{{exp_out}}}"
        step2_vars = f"a^{{{final_pow_a}}} b^{{{final_pow_b}}} c^{{{final_pow_c}}}"
        step2 = f"{step2_coeff} {step2_vars}"

        return {
            "exp_out": exp_out,
            "prob_num": prob_num,
            "prob_den": prob_den,
            "step1": step1,
            "step2": step2,
            "final_res": final_res
        }