from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Target solution (x, y)
        # Constraint: x must be negative
        x_sol = randint(-9, -1)
        y_sol = randint(-9, 9)
        
        # Calculate constants a and b
        # Eq 1: x - y = a
        a = x_sol - y_sol
        
        # Eq 2: x + y = b
        b = x_sol + y_sol
        
        # LaTeX strings
        system_latex = r"\begin{cases} x - y = %s \\ x + y = %s \end{cases}" % (a, b)
        
        # Solution Steps
        
        # Step 1: Isolate x from eq 1
        # x - y = a  ->  x = y + a
        isol_x_initial = f"x - y = {a}"
        
        if a >= 0:
            isol_x = f"y + {a}"
            isol_x_disp = f"x = y + {a}"
        else:
            isol_x = f"y - {abs(a)}"
            isol_x_disp = f"x = y - {abs(a)}"
            
        # Step 2: Substitute into eq 2
        # (y + a) + y = b
        sub_step = f"({isol_x}) + y = {b}"
        
        # Step 3: Combine like terms
        # 2y + a = b
        if a >= 0:
            combine_step = f"2y + {a} = {b}"
        else:
            combine_step = f"2y - {abs(a)} = {b}"
            
        # Step 4: Isolate 2y
        # 2y = b - a
        rhs = b - a
        isolate_y_step = f"2y = {rhs}"
        
        # Step 5: Solve for y
        y_ans_step = f"y = {y_sol}"
        
        # Step 6: Back substitute
        # x = y + a
        back_sub = f"x = {y_sol} + ({a})" if a < 0 else f"x = {y_sol} + {a}"
        x_ans_step = f"x = {x_sol}"
        
        solution_pair = f"({x_sol}, {y_sol})"

        return {
            "system_latex": system_latex,
            "isol_x_initial": isol_x_initial,
            "isol_x_disp": isol_x_disp,
            "sub_step": sub_step,
            "combine_step": combine_step,
            "isolate_y_step": isolate_y_step,
            "y_ans_step": y_ans_step,
            "back_sub": back_sub,
            "x_ans_step": x_ans_step,
            "solution_pair": solution_pair
        }