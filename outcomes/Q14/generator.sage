from sage.all import *
from random import randint, choice, shuffle, sample

class Generator(BaseGenerator):
    def data(self):
        # Loop until we find a function where f(0) is a nice integer lattice point
        while True:
            # 1. Define the Function f(x) = a(x-h)^2 + k
            a_opts = [1, -1, 0.5, -0.5, 0.25, -0.25]
            a = choice(a_opts)
            h = randint(-3, 3)
            k = randint(-3, 3)
            
            def f(x_val):
                return a * (x_val - h)**2 + k
            
            # 2. Find valid integer points
            valid_x = []
            for x_test in range(-9, 10):
                y_test = f(x_test)
                # Check if y is integer and on grid
                if abs(y_test - round(y_test)) < 0.001:
                    if -10 <= y_test <= 10:
                        valid_x.append(x_test)
            
            # Constraint: 0 MUST be a valid lattice point for this problem
            if 0 not in valid_x:
                continue
                
            # Constraint: Need at least 3 valid points (0 + 2 others)
            if len(valid_x) < 3:
                continue
            
            # Make sure we have enough distinct non-zero points to sample from
            pool = [x for x in valid_x if x != 0]
            if len(pool) < 2:
                continue
                
            break
            
        # 3. Select Questions
        
        # Mandatory: f(0)
        selected_x = [0]
        
        # Pick 2 other distinct x-values from valid_x excluding 0
        selected_x.extend(sample(pool, 2))
        
        # Shuffle these 3 to assign to (a), (b), (c) randomly
        shuffle(selected_x)
        x_a, x_b, x_c = selected_x[0], selected_x[1], selected_x[2]
        
        # Part (d): Inverse question f(x) = y
        # Always use the vertex y-coordinate so there is only one x answer.
        target_y = k
        ans_d = f"{h}"
            
        # Answers
        ans_a = int(round(f(x_a)))
        ans_b = int(round(f(x_b)))
        ans_c = int(round(f(x_c)))
        
        # 4. TikZ Graph Construction
        
        # Determine plotting domain
        t_min, t_max = -10.0, 10.0
        limit_y = 10 if a > 0 else -10
        val = (limit_y - k) / float(a)
        if val >= 0:
            dist = sqrt(val)
            t_min = max(-10.0, h - dist)
            t_max = min(10.0, h + dist)
            
        # Generate TikZ
        # UPDATED: step=1cm for grid lines at every integer
        tikz = r"""
\begin{tikzpicture}[scale=0.35]
    \draw[step=1cm, gray!40, very thin] (-10,-10) grid (10,10);
    \draw[thick, <->] (-10.5,0) -- (10.5,0) node[right] {$x$};
    \draw[thick, <->] (0,-10.5) -- (0,10.5) node[above] {$y$};
    
    \foreach \x in {-10,-8,...,10} \draw (\x, 0.1) -- (\x, -0.1) node[below] {\tiny $\x$};
    \foreach \y in {-10,-8,...,10} \draw (0.1, \y) -- (-0.1, \y) node[left] {\tiny $\y$};
    
    \draw[ultra thick, blue, <->, domain=%s:%s, samples=100] plot (\x, {%s*(\x - %s)^2 + %s});
\end{tikzpicture}
        """ 
        
        tikz_code = tikz % (t_min, t_max, a, h, k)

        return {
            "tikz": tikz_code,
            "qa_expr": f"f({x_a})",
            "ans_a": ans_a,
            "qb_expr": f"f({x_b})",
            "ans_b": ans_b,
            "qc_expr": f"f({x_c})",
            "ans_c": ans_c,
            "target_y": target_y,
            "ans_d": ans_d
        }