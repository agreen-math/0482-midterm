from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # Helper to generate a non-zero quadratic coeff
        def get_a():
            a = randint(-5, 5)
            while a == 0: a = randint(-5, 5)
            return a
            
        def get_c():
            return randint(-9, 9)

        # Polynomial 1: ax^2 + bx + c
        a1, b1, c1 = get_a(), get_c(), get_c()
        P1 = a1*x**2 + b1*x + c1
        
        # Polynomial 2: dx^2 + ex + f
        a2, b2, c2 = get_a(), get_c(), get_c()
        # Ensure the x^2 terms don't cancel out completely (optional, but keeps it quadratic)
        while a1 - a2 == 0:
            a2 = get_a()
            
        P2 = a2*x**2 + b2*x + c2
        
        # Final Answer
        Final = P1 - P2
        
        # --- Formatting the Solution Steps ---
        
        # Step 1: Distribute the negative sign
        # We need to construct the string of P1 terms followed by -P2 terms
        
        # Negate P2 coefficients
        na2, nb2, nc2 = -a2, -b2, -c2
        
        # Helper to format a term with sign, handling the "leading positive" case
        def fmt_term(coeff, power, is_first=False):
            if coeff == 0: return ""
            
            # Absolute value part
            val = abs(coeff)
            if val == 1 and power > 0:
                val_str = "" # distinct from "1"
            else:
                val_str = str(val)
                
            var_str = ""
            if power == 2: var_str = "x^2"
            elif power == 1: var_str = "x"
            
            term = f"{val_str}{var_str}"
            
            # Sign part
            if coeff > 0:
                sign = "+" if not is_first else ""
            else:
                sign = "-"
                
            return f"{sign}{term}"

        # Construct the "Distribute Negatives" line (e.g., x^2 - 6x + 9 - 3x^2 + 7x - 2)
        # P1 terms
        s_p1_a = fmt_term(a1, 2, True)
        s_p1_b = fmt_term(b1, 1, False)
        s_p1_c = fmt_term(c1, 0, False) # Constant always needs sign unless it's the very first number (unlikely here)
        
        # -P2 terms
        s_p2_a = fmt_term(na2, 2, False)
        s_p2_b = fmt_term(nb2, 1, False)
        s_p2_c = fmt_term(nc2, 0, False)
        
        # Join them (filtering out empty strings from 0 coeffs)
        step1_parts = [s_p1_a, s_p1_b, s_p1_c, s_p2_a, s_p2_b, s_p2_c]
        step1_str = "".join(step1_parts)
        
        # Step 2: Group Like Terms (e.g., x^2 - 3x^2 - 6x + 7x + 9 - 2)
        # Order: x^2s, then xs, then constants
        group_parts = [s_p1_a, s_p2_a, s_p1_b, s_p2_b, s_p1_c, s_p2_c]
        step2_str = "".join(group_parts)
        
        return {
            "P1": P1,
            "P2": P2,
            "step1": step1_str,
            "step2": step2_str,
            "Final": Final
        }