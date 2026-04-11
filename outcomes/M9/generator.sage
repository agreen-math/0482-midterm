from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Scenario pools: (Coeff1, Var1, Coeff2, Var2, Constant)
        # All lowercase to avoid confusion
        scenarios = [
            ('a', 'x', 'b', 'y', 'c'),
            ('m', 'x', 'n', 'y', 'p'),
            ('d', 'x', 'e', 'y', 'f'),
            ('r', 'x', 's', 'y', 't'),
        ]
        
        c1, v1, c2, v2, k = choice(scenarios)
        
        # Operation: + or -
        sign = choice(['+', '-'])
        
        # Determine target variable: Solve for v1 or v2?
        solve_for_v2 = choice([True, False])
        
        if solve_for_v2:
            target = v2
            # Equation: c1 v1 +/- c2 v2 = k
            eqn = f"{c1}{v1} {sign} {c2}{v2} = {k}"
            
            if sign == '+':
                # c2 v2 = k - c1 v1
                step1 = f"{c2}{v2} = {k} - {c1}{v1}"
                numerator = f"{k} - {c1}{v1}"
                denominator = c2
            else:
                # c1 v1 - c2 v2 = k
                # -c2 v2 = k - c1 v1
                # Multiply by -1: c2 v2 = c1 v1 - k
                step1 = f"-{c2}{v2} = {k} - {c1}{v1}"
                numerator = f"{c1}{v1} - {k}" 
                denominator = c2
                
        else: # Solve for v1
            target = v1
            eqn = f"{c1}{v1} {sign} {c2}{v2} = {k}"
            
            if sign == '+':
                # c1 v1 = k - c2 v2
                step1 = f"{c1}{v1} = {k} - {c2}{v2}"
                numerator = f"{k} - {c2}{v2}"
            else:
                # c1 v1 - c2 v2 = k
                # c1 v1 = k + c2 v2
                step1 = f"{c1}{v1} = {k} + {c2}{v2}"
                numerator = f"{k} + {c2}{v2}"
            
            denominator = c1

        # Final Answer String
        final = f"{target} = \\frac{{{numerator}}}{{{denominator}}}"

        return {
            "eqn": eqn,
            "target": target,
            "step1": step1,
            "final": final
        }