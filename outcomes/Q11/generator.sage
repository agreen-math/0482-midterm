from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Goal: Intercepts must be integers within [-10, 10].
        # Strategy: Pick the intercepts, then find the slope.
        
        # 1. Pick Intercepts (avoid 0 to ensure distinct non-origin intercepts)
        # Keep range inside -9 to 9 so they aren't on the very edge
        x_int = randint(-9, 9)
        while x_int == 0: x_int = randint(-9, 9)
        
        y_int = randint(-9, 9)
        while y_int == 0: y_int = randint(-9, 9)
        
        # 2. Calculate Slope and Equation
        # Slope m = (y2 - y1) / (x2 - x1) = (0 - y_int) / (x_int - 0) = -y_int / x_int
        m_val = Rational(-y_int) / Rational(x_int)
        
        # Equation string: f(x) = mx + b
        # Helper to format slope nicely
        if m_val == 1:
            m_str = ""
        elif m_val == -1:
            m_str = "-"
        else:
            m_str = latex(m_val)
            
        # y-intercept is b (since x=0)
        b_val = y_int
        if b_val > 0:
            eqn = f"{m_str}x + {b_val}"
        else:
            eqn = f"{m_str}x - {abs(b_val)}"
            
        # 3. TikZ Generation
        # We generate the code string here to ensure the plotting logic matches the math
        
        def get_tikz(show_sol=False):
            # Scale 0.4 fits well on a page
            tikz = [r"\begin{tikzpicture}[scale=0.4]"]
            
            # Grid and Axes
            tikz.append(r"\draw[help lines, color=gray!50] (-10,-10) grid (10,10);")
            tikz.append(r"\draw[<->, thick] (-10.5,0)--(10.5,0) node[right]{$x$};")
            tikz.append(r"\draw[<->, thick] (0,-10.5)--(0,10.5) node[above]{$y$};")
            
            if show_sol:
                # Plot the line
                # We use \clip to make sure the arrows don't go crazy outside the box
                tikz.append(r"\begin{scope}")
                tikz.append(r"\clip (-10,-10) rectangle (10,10);")
                # Domain -11:11 to ensure it crosses the borders
                # Syntax: \draw plot (\x, m*\x + b)
                # Note: TikZ handles fractions like -5/2 usually okay, but decimals are safer.
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