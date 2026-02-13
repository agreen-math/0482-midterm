from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Goal: Intercepts must be integers within [-10, 10].
        # Constraint: Slope must be a fraction (denominator != 1).
        
        while True:
            # 1. Pick Intercepts
            # Keep range inside -9 to 9 so they aren't on the very edge
            x_int = randint(-9, 9)
            if x_int == 0: continue
            
            y_int = randint(-9, 9)
            if y_int == 0: continue
            
            # 2. Check Slope
            # Slope m = -y_int / x_int
            # We want to ensure m is NOT an integer.
            if y_int % x_int == 0:
                continue
                
            # If we get here, the slope is a fraction.
            break
        
        m_val = Rational(-y_int) / Rational(x_int)
        
        # Format slope with displaystyle braces as requested
        # Since we guaranteed it's a fraction, we always apply this format.
        m_str = r"\displaystyle{" + latex(m_val) + "}"
            
        # y-intercept is b
        b_val = y_int
        
        # Build Equation String
        if b_val > 0:
            eqn = f"{m_str}x + {b_val}"
        else:
            eqn = f"{m_str}x - {abs(b_val)}"
            
        # 3. TikZ Generation
        def get_tikz(show_sol=False):
            # Scale 0.4 fits well on a page
            tikz = [r"\begin{tikzpicture}[scale=0.4]"]
            
            # Grid and Axes
            tikz.append(r"\draw[help lines, color=gray!50] (-10,-10) grid (10,10);")
            tikz.append(r"\draw[<->, thick] (-10.5,0)--(10.5,0) node[right]{$x$};")
            tikz.append(r"\draw[<->, thick] (0,-10.5)--(0,10.5) node[above]{$y$};")
            
            if show_sol:
                # Plot the line
                tikz.append(r"\begin{scope}")
                tikz.append(r"\clip (-10,-10) rectangle (10,10);")
                
                m_float = float(m_val)
                b_float = float(b_val)
                tikz.append(rf"\draw[<->, ultra thick, blue, domain=-11:11, samples=2] plot (\x, {{{m_float}*\x + {b_float}}});")
                tikz.append(r"\end{scope}")
                
                # Plot the intercept dots
                tikz.append(rf"\fill[red] ({x_int},0) circle (0.3);")
                tikz.append(rf"\fill[red] (0,{y_int}) circle (0.3);")
                
            tikz.append(r"\end{tikzpicture}")
            return "\n".join(tikz)

        return {
            "eqn": eqn,
            "slope": latex(m_val),
            "y_int": y_int,
            "x_int": x_int,
            "grid_tikz": get_tikz(show_sol=False),
            "solution_tikz": get_tikz(show_sol=True)
        }