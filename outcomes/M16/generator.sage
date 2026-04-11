from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Function: R(n) = (1/a)n + b
        # Constraints: a, b positive integers. a != 1. b < target_rank.
        
        a = randint(5, 25) # Denominator, e.g., 10, 15, 20
        b = randint(1, 5)  # y-intercept, small positive integer
        
        # Target Rank: Must be greater than b so n is positive
        target_rank = randint(b + 2, b + 15)
        
        # Equation string
        eqn = f"R(n) = \\frac{{1}}{{{a}}}n + {b}"
        
        # Solution Steps
        # Step 1: Substitute
        # 7 = (1/10)n + 1
        step1 = f"{target_rank} = \\frac{{1}}{{{a}}}n + {b}"
        
        # Step 2: Subtract b
        # 6 = (1/10)n
        diff = target_rank - b
        step2 = f"{diff} = \\frac{{1}}{{{a}}}n"
        
        # Step 3: Multiply by a
        # 60 = n
        ans = a * diff
        step3 = f"{ans} = n"
        
        return {
            "eqn": eqn,
            "target_rank": target_rank,
            "step1": step1,
            "step2": step2,
            "step3": step3,
            "ans": ans
        }