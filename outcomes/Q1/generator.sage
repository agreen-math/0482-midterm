from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Template: A - B(C - |D - E^2|)
        
        while True:
            # 1. Exponent part (E^2)
            # Keep E between 3 and 6
            E = randint(3, 6)
            E_sq = E**2
            
            # 2. Absolute Value part (|D - E^2|)
            # We need D - E^2 to be NEGATIVE.
            # D must be at least 2
            if E_sq - 5 < 2: continue
            
            D = randint(2, E_sq - 5) 
            
            inner_diff = D - E_sq  # This is negative
            abs_val = abs(inner_diff)
            
            # CRITICAL CHECK: 
            # We need space to pick C such that C < abs_val - 2.
            # So abs_val must be at least 7 (since min C is 5).
            if abs_val < 8:
                continue
            
            # 3. Parentheses part (C - abs_val)
            # We want this result to be NEGATIVE.
            C = randint(5, abs_val - 2)
            
            paren_val = C - abs_val # This is negative
            
            # 4. Outer parts
            B = randint(2, 5) # Multiplier
            A = randint(2, 15) # Leading term
            
            # Calculate Final Result
            prod = B * paren_val
            final = A - prod

            return {
                "A": A,
                "B": B,
                "C": C,
                "D": D,
                "E": E,
                "E_sq": E_sq,
                "inner_diff": inner_diff,
                "abs_val": abs_val,
                "paren_val": paren_val,
                "prod": prod,
                "final": final
            }