from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # 1. Choose LCD and Denominators
        # We want denominators d1, d2 such that lcm(d1, d2) is a nice number (10-30)
        # Pattern from screenshot: 5 and 15. LCD is 15.
        
        lcd_choices = [6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 24]
        LCD = choice(lcd_choices)
        
        # Pick d1 (for x term) and d2 (constant term) as divisors of LCD
        divs = divisors(LCD)
        # Exclude 1 to force fractions.
        valid_divs = [d for d in divs if d > 1]
        
        d1 = choice(valid_divs)
        d2 = choice(valid_divs)
        
        # Ensure at least one denom IS the LCD (to match the complexity of "clearing" completely)
        # or at least that their LCM is the LCD we picked.
        while lcm(d1, d2) != LCD:
            d1 = choice(valid_divs)
            d2 = choice(valid_divs)
            
        # 2. Numerators
        # Make sure n/d is somewhat simplified or at least reasonable
        n1 = randint(1, d1-1)
        # Ensure n1/d1 isn't an integer (already covered since n1 < d1)
        
        n2 = randint(1, d2-1)
        
        # 3. Constant RHS
        rhs = randint(1, 5) * choice([-1, 1])
        
        # 4. Operation (Add or Subtract)
        op = choice(['+', '-'])
        
        # 5. Build Equation Objects for Display
        # Term 1: (n1/d1)x
        term1_coeff = Integer(n1)/Integer(d1)
        
        # Term 2: (n2/d2)
        term2_const = Integer(n2)/Integer(d2)
        
        # Build String
        if op == '+':
            eqn_str = f"\\frac{{{n1}}}{{{d1}}}x + \\frac{{{n2}}}{{{d2}}} = {rhs}"
            # Integer Equation Logic: A x + B = C_new
            # A = n1 * (LCD/d1)
            # B = n2 * (LCD/d2)
            # C_new = rhs * LCD
            
            A = n1 * (LCD // d1)
            B = n2 * (LCD // d2)
            C_new = rhs * LCD
            
            # Solution logic: Ax = C_new - B
            RHS_final = C_new - B
            
        else: # Subtract
            eqn_str = f"\\frac{{{n1}}}{{{d1}}}x - \\frac{{{n2}}}{{{d2}}} = {rhs}"
            
            A = n1 * (LCD // d1)
            B = n2 * (LCD // d2)
            C_new = rhs * LCD
            
            # Solution logic: Ax = C_new + B
            RHS_final = C_new + B
            
        # Final Solution
        final_x = Integer(RHS_final) / Integer(A)
        
        # --- Solution Step Strings ---
        
        # Step 1: Multiply by LCD
        # "15 * (4/5 x) - 15 * (2/15) = 15 * 2"
        # Let's simplify display to: A x (+/-) B = C_new
        op_char = "+" if op == '+' else "-"
        
        step1 = f"{LCD} \\left( {eqn_str} \\right)"
        step2 = f"{A}x {op_char} {B} = {C_new}"
        
        # Step 3: Isolate term
        step3 = f"{A}x = {RHS_final}"
        
        # Step 4: Final Answer
        # Show unsimplified first if different
        if RHS_final % A != 0 and gcd(RHS_final, A) > 1:
            step4 = f"x = \\frac{{{RHS_final}}}{{{A}}}"
            step5 = f"x = {latex(final_x)}"
        elif RHS_final % A != 0:
             step4 = f"x = \\frac{{{RHS_final}}}{{{A}}}"
             step5 = "" # Same as step4
        else:
             step4 = f"x = {RHS_final // A}"
             step5 = ""

        return {
            "equation": eqn_str,
            "LCD": LCD,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "step4": step4,
            "step5": step5,
            "final": latex(final_x)
        }