from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Pattern: (Ax - By)(A^2x^2 + ABxy + B^2y^2)
        # Result: A^3x^3 - B^3y^3
        
        # 1. Generate Coefficients A and B
        # Keep them small so squares and cubes don't explode
        A = randint(2, 5)
        B = randint(1, 4)
        
        # 2. Variable names (mix it up occasionally, but usually x,y or a,b)
        # Screenshot used 'a' and 'b'. Let's stick to that or 'x' and 'y'.
        v1, v2 = choice([('x', 'y'), ('a', 'b'), ('u', 'v')])
        
        # 3. Construct Terms
        # Binomial terms
        term_bin_1 = f"{A}{v1}"
        term_bin_2 = f"{B}{v2}" if B > 1 else f"{v2}"
        
        # Trinomial terms
        A_sq = A**2
        AB = A * B
        B_sq = B**2
        
        term_tri_1 = f"{A_sq}{v1}^2"
        term_tri_2 = f"{AB}{v1}{v2}"
        term_tri_3 = f"{B_sq}{v2}^2" if B > 1 else f"{v2}^2"
        
        # 4. Construct Full Expressions
        binomial = f"{term_bin_1} - {term_bin_2}"
        trinomial = f"{term_tri_1} + {term_tri_2} + {term_tri_3}"
        
        # 5. Final Result
        A_cu = A**3
        B_cu = B**3
        term_final_1 = f"{A_cu}{v1}^3"
        term_final_2 = f"{B_cu}{v2}^3" if B > 1 else f"{v2}^3"
        
        final_res = f"{term_final_1} - {term_final_2}"
        
        # --- Solution Steps ---
        
        # Step 1: Distribution Setup
        # e.g., 3a(9a^2 + 3ab + b^2) - b(9a^2 + 3ab + b^2)
        step1_p1 = f"{term_bin_1}({trinomial})"
        step1_p2 = f"{term_bin_2}({trinomial})"
        step1 = f"{step1_p1} - {step1_p2}"
        
        # Step 2: Expanded Terms
        # A*A^2, A*AB, A*B^2  MINUS  B*A^2, B*AB, B*B^2
        # Terms:
        # 1. A^3 x^3
        # 2. A^2 B x^2 y
        # 3. A B^2 x y^2
        # 4. - A^2 B x^2 y
        # 5. - A B^2 x y^2
        # 6. - B^3 y^3
        
        t1 = f"{A**3}{v1}^3"
        t2 = f"{A**2 * B}{v1}^2{v2}"
        t3 = f"{A * B**2}{v1}{v2}^2"
        
        t4 = f"{A**2 * B}{v1}^2{v2}"
        t5 = f"{A * B**2}{v1}{v2}^2"
        t6 = f"{B**3}{v2}^3" if B > 1 else f"{v2}^3"
        
        step2 = f"{t1} + {t2} + {t3} - {t4} - {t5} - {t6}"
        
        return {
            "binomial": binomial,
            "trinomial": trinomial,
            "step1": step1,
            "step2": step2,
            "final": final_res
        }