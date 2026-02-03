from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # 1. Generate Divisor (ax + b)
        da = randint(1, 3)
        db = randint(-4, 4)
        while db == 0: db = randint(-4, 4)
        divisor = da*x + db
        
        # 2. Generate Quotient (Degree 3)
        q3 = randint(1, 4) * choice([-1, 1])
        q2 = randint(-5, 5)
        q1 = randint(-5, 5)
        q0 = randint(-5, 5)
        quotient = q3*x**3 + q2*x**2 + q1*x + q0
        
        # 3. Generate Remainder
        rem_val = randint(-9, 9)
        while rem_val == 0: rem_val = randint(-9, 9)
        
        # 4. Construct Dividend
        dividend = expand(divisor * quotient + rem_val)
        
        # --- Helpers for LaTeX ---
        def poly_tex(p):
            return latex(p)

        # 5. Build Long Division Array (The Solution Block)
        # We will build a LaTeX array string manually.
        
        lines = []
        lines.append(r"\begin{array}{r}")
        
        # Line 1: Quotient
        lines.append(f"{poly_tex(quotient)} \\\\")
        
        # Line 2: Divisor ) Dividend
        # We use \overline to simulate the division bar
        lines.append(f"{poly_tex(divisor)} \\overline{{ ) {poly_tex(dividend)} }} \\\\")
        
        # Loop to generate steps
        curr_poly = dividend
        
        # We iterate through the quotient terms from highest degree to lowest
        # q3*x^3, q2*x^2, q1*x, q0
        q_coeffs = [q3, q2, q1, q0]
        degrees = [3, 2, 1, 0]
        
        for coeff, deg in zip(q_coeffs, degrees):
            # Term being multiplied
            term = coeff * x**deg
            
            # Product to subtract
            product = expand(term * divisor)
            
            # New Remainder
            new_poly = expand(curr_poly - product)
            
            # Line: Subtraction (underlined)
            # We wrap product in parens to show subtraction of the whole term
            lines.append(r"\underline{ -(" + poly_tex(product) + r") } \\\\")
            
            # Line: Resulting Remainder
            if deg > 0:
                lines.append(f"{poly_tex(new_poly)} \\\\")
            else:
                # Final step shows just the constant remainder
                lines.append(f"{rem_val}")
            
            curr_poly = new_poly

        lines.append(r"\end{array}")
        
        # Join all lines
        long_div_display = "\n".join(lines)
        
        # 6. Final Answer String
        dividend_tex = poly_tex(dividend)
        divisor_tex = poly_tex(divisor)
        quotient_tex = poly_tex(quotient)
        
        if rem_val > 0:
            sign = "+"
            r_abs = rem_val
        else:
            sign = "-"
            r_abs = abs(rem_val)
            
        final_res = f"{quotient_tex} {sign} \\frac{{{r_abs}}}{{{divisor_tex}}}"

        return {
            "dividend": dividend_tex,
            "divisor": divisor_tex,
            "final": final_res,
            "long_div_display": long_div_display
        }