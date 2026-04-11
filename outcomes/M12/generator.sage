from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        x, h = var('x h')
        
        # Form: g(x) = x^2 - Bx + C
        # B between 2 and 9 (so term is -2x to -9x)
        B = randint(2, 9)
        # C between 1 and 9 (so term is +1 to +9)
        C = randint(1, 9)
        
        # Define function for internal calc
        g(x) = x^2 - B*x + C
        
        # --- Part (a): g(-1) ---
        # Work: (-1)^2 - B(-1) + C
        val_a_step1 = f"(-1)^2 - {B}(-1) + {C}"
        val_a_step2 = f"1 + {B} + {C}"
        ans_a = g(-1)
        
        # --- Part (b): g(0) ---
        # Work: (0)^2 - B(0) + C
        val_b_step1 = f"(0)^2 - {B}(0) + {C}"
        ans_b = g(0)
        
        # --- Part (c): g(x+h) ---
        # Work: (x+h)^2 - B(x+h) + C
        val_c_step1 = f"(x+h)^2 - {B}(x+h) + {C}"
        
        # Explicit ordering for final string: x^2 + 2xh + h^2 - Bx - Bh + C
        ans_c = f"x^2 + 2xh + h^2 - {B}x - {B}h + {C}"

        return {
            "B": B,
            "C": C,
            "val_a_step1": val_a_step1,
            "val_a_step2": val_a_step2,
            "ans_a": ans_a,
            "val_b_step1": val_b_step1,
            "ans_b": ans_b,
            "val_c_step1": val_c_step1,
            "ans_c": ans_c
        }