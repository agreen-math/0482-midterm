from sage.all import *
from random import randint, choice, sample

class Generator(BaseGenerator):
    def data(self):
        while True:
            # 1. Strict Parameters for "Nice" Graphs
            # Force a=1 or -1 to guarantee integer outputs for integer inputs.
            a = choice([1, -1]) 
            
            # Force h (vertex x) to be close to 0, but NOT 0.
            # This ensures x=0 is one of the 5 "core" points (h-2 to h+2).
            # h in {-2, -1, 1, 2}
            h = choice([-2, -1, 1, 2])
            
            # Pick k (vertex y) such that the whole 5-point shape fits in [-10, 10].
            # The "tallest" point relative to vertex is at distance 2, which is 4 units away vertically.
            if a == 1:
                # Opens Up. Vertex is lowest point.
                # Lowest point k >= -10. Highest point (k+4) <= 10.
                k = randint(-10, 6)
            else:
                # Opens Down. Vertex is highest point.
                # Highest point k <= 10. Lowest point (k-4) >= -10.
                k = randint(-6, 10)
            
            def f(x_val):
                return a * (x_val - h)**2 + k
            
            # 2. Identify the 5 Core Lattice Points
            # These are guaranteed to be integers because a is integer.
            # We already mathematically ensured they are within [-10,10] Y-range via k constraints.
            core_x = [h-2, h-1, h, h+1, h+2]
            
            # Double check visibility just to be safe (should always pass)
            valid_points = []
            for x in core_x:
                if -10 <= x <= 10 and -10 <= f(x) <= 10:
                    valid_points.append(x)
            
            if len(valid_points) < 5:
                continue # Should not happen with above logic, but safety first
            
            # 3. generate Questions
            
            # Part (a): Always f(0). 0 is guaranteed to be in valid_points.
            x_a = 0
            
            # Parts (b) and (c): Pick 2 distinct points from valid_points
            # EXCLUDE the vertex (h) and the already used y-intercept (0)
            pool = [x for x in valid_points if x != h and x != 0]
            
            # We need 2 points. Pool size should be exactly 3 (5 total - vertex - yint).
            if len(pool) < 2:
                continue
                
            selected_bc = sample(pool, 2)
            x_b = selected_bc[0]
            x_c = selected_bc[1]
            
            # Part (d): Vertex x-value
            # We ask "Find x where f(x) = k"
            target_y = k
            ans_d = f"{h}"
            
            # Calculate Answers
            ans_a = int(f(x_a))
            ans_b = int(f(x_b))
            ans_c = int(f(x_c))
            
            # 4. TikZ Graph
            # Calculate plotting domain so arrows touch edges or grid bounds
            t_min, t_max = -10.0, 10.0
            limit_y = 10 if a > 0 else -10
            
            # Solve a(x-h)^2 + k = limit_y
            val = (limit_y - k) / float(a) 
            if val >= 0:
                dist = sqrt(val)
                t_min = max(-10.0, h - dist)
                t_max = min(10.0, h + dist)
                
            # Build TikZ
            tikz = r"""
\begin{tikzpicture}[scale=0.35]
    \draw[step=1cm, gray!40, very thin] (-10,-10) grid (10,10);
    \draw[thick, <->] (-10.5,0) -- (10.5,0) node[right] {$x$};
    \draw[thick, <->] (0,-10.5) -- (0,10.5) node[above] {$y$};
    
    \foreach \x in {-10,-8,...,10} \draw (\x, 0.1) -- (\x, -0.1) node[below] {\tiny $\x$};
    \foreach \y in {-10,-8,...,10} \draw (0.1, \y) -- (-0.1, \y) node[left] {\tiny $\y$};
    
    \draw[ultra thick, blue, <->, domain=%s:%s, samples=100] plot (\x, {%s*(\x - %s)^2 + %s});
\end{tikzpicture}
            """ % (t_min, t_max, a, h, k)

            return {
                "tikz": tikz,
                "qa_expr": f"f({x_a})",
                "ans_a": ans_a,
                "qb_expr": f"f({x_b})",
                "ans_b": ans_b,
                "qc_expr": f"f({x_c})",
                "ans_c": ans_c,
                "target_y": target_y,
                "ans_d": ans_d
            }