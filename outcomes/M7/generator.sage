from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x = var('x')
        
        # 1. Pick the Solution first (Keep it small integer)
        # Example had x = 1. Let's do -5 to 5.
        sol = randint(-5, 5)
        
        # 2. Build the Left Side: A - B(Cx - D)
        # We need to pick B, C, D first, calculate value at x=sol, then pick A.
        
        B = randint(2, 6) # Multiplier (positive, but subtracted)
        C = randint(2, 5) # Coeff of x
        D = randint(1, 9) # Constant inside
        
        # Inner value at sol
        inner_left_val = C*sol - D
        
        # Term being subtracted
        sub_val = B * inner_left_val
        
        # Pick A (Constant term out front)
        A = randint(5, 20)
        
        # Calculate the total value of the Left Side
        LHS_val = A - sub_val
        
        # 3. Build the Right Side: E(Fx - G)
        # We need E * (F*sol - G) == LHS_val
        
        # Pick E (Multiplier)
        # To ensure we can find F and G, let's pick E such that it divides LHS_val?
        # Or easier: Construct the side fully then adjust.
        
        # Let's try: Pick E and F, then solve for G.
        E = randint(2, 5)
        F = randint(2, 6)
        
        # We need E(F*sol - G) = LHS_val
        # F*sol - G = LHS_val / E
        # This requires LHS_val to be divisible by E.
        # If not, let's adjust A on the left side to make it divisible.
        
        rem = LHS_val % E
        if rem != 0:
            # Add/Sub from A to fix divisibility
            offset = E - rem
            A += offset
            LHS_val += offset
            
        # Now we know inner_right_val
        inner_right_val = LHS_val // E
        
        # F*sol - G = inner_right_val
        # G = F*sol - inner_right_val
        G = F*sol - inner_right_val
        
        # Formatting for display to handle signs of G and D
        # Form: A - B(Cx - D) = E(Fx - G)
        # If D or G are negative, it shows as (Cx - -5) which is ugly.
        # Let's adjust the generated strings.
        
        # Left Side String construction
        if D > 0:
            left_inner = f"{C}x - {D}"
        elif D < 0:
            left_inner = f"{C}x + {abs(D)}"
        else:
            left_inner = f"{C}x"
            
        # Right Side String construction
        if G > 0:
            right_inner = f"{F}x - {G}"
        elif G < 0:
            right_inner = f"{F}x + {abs(G)}"
        else:
            right_inner = f"{F}x"
            
        equation = f"{A} - {B}({left_inner}) = {E}({right_inner})"
        
        # --- Solution Steps Data ---
        
        # Step 1: Distribute
        # Left: A - B*C x + B*D
        dist_left_const = -B * (-D) # + product
        term_left_x = -B * C
        
        # Right: E*F x - E*G
        term_right_x = E * F
        dist_right_const = E * (-G)
        
        # String: A - BCx + BD = EFx - EG
        # Handle signs for display
        def fmt(val, is_leading=False):
            if val >= 0: return f"+ {val}" if not is_leading else f"{val}"
            return f"- {abs(val)}"
            
        step1_left = f"{A} {fmt(term_left_x)}x {fmt(dist_left_const)}"
        step1_right = f"{term_right_x}x {fmt(dist_right_const)}"
        
        # Step 2: Combine Like Terms on Left
        # (A + dist_left_const) - BCx
        comb_left_const = A + dist_left_const
        step2_left = f"{comb_left_const} {fmt(term_left_x)}x"
        
        # Step 3: Move variables (add BCx to both sides)
        # comb_left_const = (term_right_x - term_left_x)x + dist_right_const
        # Note: term_left_x is negative, so subtracting it adds to right
        coeff_x_final = term_right_x - term_left_x
        step3 = f"{comb_left_const} = {coeff_x_final}x {fmt(dist_right_const)}"
        
        # Step 4: Move constants (subtract dist_right_const)
        # comb_left - dist_right = coeff_x_final x
        final_const = comb_left_const - dist_right_const
        step4 = f"{final_const} = {coeff_x_final}x"

        return {
            "equation": equation,
            "step1_left": step1_left,
            "step1_right": step1_right,
            "step2_left": step2_left,
            "step3": step3,
            "step4": step4,
            "sol": sol
        }