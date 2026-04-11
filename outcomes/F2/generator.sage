from sage.all import *
from random import randint, choice
import math

class Generator(BaseGenerator):
    def data(self):
        # 1. Select a variable for the polynomial
        v_str = choice(['x', 'y', 'z', 'a', 'm'])
        v = var(v_str)

        # 2. Determine the target GCF
        # Coefficient between 2 and 10, Exponent between 1 and 5
        C = choice([2, 3, 4, 5, 6, 7, 8, 9, 10])
        E = randint(1, 5)
        gcf_term = C * v**E

        # 3. Generate the "inside" trinomial (ax^2 + bx + c, etc.)
        # Ensure the remaining coefficients share NO common factors
        while True:
            a = randint(2, 9)
            b = choice([-9, -8, -7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9])
            c = choice([-9, -8, -7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9])
            if math.gcd(a, math.gcd(abs(b), abs(c))) == 1:
                break

        # Pick random descending exponents for the inside trinomial
        e_a = choice([2, 3, 4])
        e_b = randint(1, e_a - 1)

        # Construct the inside polynomial
        inside_poly = a*v**e_a + b*v**e_b + c

        # 4. Multiply to get the original expanded polynomial
        poly = expand(gcf_term * inside_poly)

        # 5. Format LaTeX
        # Use \left( and \right) to ensure the parentheses scale nicely around the expression
        # Safely wrap the answer in a LaTeX box here in Python
        ans_latex = f"\\boxed{{{latex(gcf_term)}\\left({latex(inside_poly)}\\right)}}"

        return {
            "poly_latex": latex(poly),
            "gcf_latex": latex(gcf_term),
            "ans_latex": ans_latex
        }