from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Template: A * root(index, -B)
        
        # 1. Pick the root index (mostly 3, rarely 5 to keep numbers manageable)
        index = choice([3, 3, 3, 5])
        
        # 2. Pick the 'perfect' part that will escape the root
        # Base 'p' such that (-p)^index is the perfect factor
        p = randint(2, 4) 
        perfect_part = p**index
        
        # 3. Pick the 'leftover' part that stays inside
        # Keep it small and square-free relative to the index if possible
        leftover = choice([2, 3, 4, 5, 6, 7])
        
        # Check to ensure leftover isn't a perfect power itself 
        # (e.g., if index=3, leftover shouldn't be 8)
        if leftover == 4 and index == 2: leftover = 3 # Safety catch, though index is odd
        
        # 4. Construct the negative radicand
        # We want the negative sign to be associated with the perfect part for extraction
        radicand_val = -1 * perfect_part * leftover
        
        # 5. Outside multiplier A
        A = randint(2, 9)
        
        # 6. Solution components
        # Step 1: Split radicand -> (-1 * p^index) * leftover
        # Step 2: Extract root -> -p
        extracted = -p
        
        # Step 3: Multiply by A
        coeff_final = A * extracted
        
        return {
            "index": index,
            "radicand": radicand_val,
            "A": A,
            "perfect_part": perfect_part, # Positive version for display steps
            "leftover": leftover,
            "p": p,
            "extracted": extracted,
            "coeff_final": coeff_final
        }