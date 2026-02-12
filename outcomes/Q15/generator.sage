from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        while True:
            # 1. Define Line 1 (Ax - By = C)
            # A is usually positive, B_mag is positive so term is -By
            A = randint(2, 6)
            B_mag = randint(2, 8) 
            B = -B_mag # The coefficient in the equation
            C = randint(1, 10) * choice([-1, 1])
            
            # Equation string: Ax - By = C
            given_eqn = f"{A}x - {B_mag}y = {C}"
            
            # Calculate Slope m = -A/B = -A/-B_mag = A/B_mag
            m = Rational(A) / Rational(B_mag)
            
            # 2. Define Point (x1, y1)
            # Both negative coordinates to match the difficulty request
            x1 = randint(-6, -1)
            y1 = randint(-6, -1)
            point_str = f"({x1}, {y1})"
            
            # 3. Solve for new line
            # Parallel -> same slope m
            # y = mx + b  ->  b = y - mx
            b_val = y1 - (m * x1)
            
            # Constraint: b cannot be zero
            if b_val == 0:
                continue
                
            break
        
        # 4. Generate Step-by-Step Solution Strings
        
        # Slope Calculation
        # Ax - By = C -> -By = -Ax + C
        step1_line1 = f"{B}y = -{A}x + {C}"
        
        # y = (A/B_mag)x + (C/B)
        m_latex = latex(m)
        step1_line2 = f"y = {m_latex}x + {latex(Rational(C)/Rational(B))}"
        
        # Y-intercept Calculation
        # Plug into y = mx + b
        step2_line1 = f"{y1} = {m_latex}({x1}) + b"
        
        # Simplify m*x1
        mx1 = m * x1
        step2_line2 = f"{y1} = {latex(mx1)} + b"
        
        # Result for b
        step2_line3 = f"b = {latex(b_val)}"
        
        # Final Equation
        if b_val > 0:
            final_eqn = f"y = {m_latex}x + {latex(b_val)}"
        else:
            final_eqn = f"y = {m_latex}x - {latex(abs(b_val))}"

        return {
            "given_eqn": given_eqn,
            "point": point_str,
            "step1_line1": step1_line1,
            "step1_line2": step1_line2,
            "m": m_latex,
            "step2_line1": step2_line1,
            "step2_line2": step2_line2,
            "step2_line3": step2_line3,
            "final_eqn": final_eqn
        }