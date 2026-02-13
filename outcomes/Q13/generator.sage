from sage.all import *
from random import randint, choice, shuffle

class Generator(BaseGenerator):
    def data(self):
        # --- Helper: Solve for plotting bounds ---
        def get_valid_domain(eqn_type, a, h, k):
            t_min, t_max = -10.0, 10.0
            try:
                if eqn_type == 'quadratic':
                    target = 10 if a > 0 else -10
                    val = (target - k) / a
                    if val >= 0:
                        dist = float(sqrt(val))
                        t_min = max(t_min, h - dist)
                        t_max = min(t_max, h + dist)
                elif eqn_type == 'cubic':
                    def get_x(y_val):
                        term = (y_val - k) / a
                        sign = 1 if term > 0 else -1
                        return h + sign * (abs(term)**(1/3.0))
                    x1 = get_x(-10)
                    x2 = get_x(10)
                    t_min = max(t_min, min(x1, x2))
                    t_max = min(t_max, max(x1, x2))
                elif eqn_type == 'sideways':
                    target = 10 if a > 0 else -10
                    val = (target - h) / a
                    if val >= 0:
                        dist = float(sqrt(val))
                        t_min = max(t_min, k - dist)
                        t_max = min(t_max, k + dist)
            except Exception:
                pass
            return t_min, t_max

        # --- Helper: Generate TikZ string with Labels ---
        # Note: No LaTeX comments (%) allowed in this string to avoid Python formatting errors
        def get_tikz(plot_cmd, t_min, t_max):
            return r"""
\begin{tikzpicture}[scale=0.35]
    \draw[step=1cm, gray!40, very thin] (-10,-10) grid (10,10);
    \draw[thick, <->] (-10.5,0) -- (10.5,0) node[right] {$x$};
    \draw[thick, <->] (0,-10.5) -- (0,10.5) node[above] {$y$};
    
    \foreach \x in {-10,-8,...,10} \draw (\x, 0.1) -- (\x, -0.1) node[below] {\tiny $\x$};
    \foreach \y in {-10,-8,...,10} \draw (0.1, \y) -- (-0.1, \y) node[left] {\tiny $\y$};
    
    \draw[ultra thick, blue, <->, domain=%s:%s, samples=100] plot %s;
\end{tikzpicture}
            """ % (t_min, t_max, plot_cmd)

        # --- Scenario 1: The Function ---
        func_type = choice(['quadratic', 'cubic'])
        
        if func_type == 'quadratic':
            a = choice([-1, 1]) * choice([0.5, 0.25])
            h = randint(-3, 3)
            k = randint(-3, 3)
            t_min, t_max = get_valid_domain('quadratic', a, h, k)
            tikz_func_cmd = f"(\\x, {{{a}*(\\x - {h})^2 + {k}}})"
            dom_func = r"(-\infty, \infty)"
            rng_func = f"[{k}, \\infty)" if a > 0 else f"(-\\infty, {k}]"
                
        else: # Cubic
            a = choice([-1, 1]) * choice([0.1, 0.2])
            h = randint(-2, 2)
            k = randint(-2, 2)
            t_min, t_max = get_valid_domain('cubic', a, h, k)
            tikz_func_cmd = f"(\\x, {{{a}*(\\x - {h})^3 + {k}}})"
            dom_func = r"(-\infty, \infty)"
            rng_func = r"(-\infty, \infty)"

        func_data = {
            "is_function": "Function",
            "domain": dom_func,
            "range": rng_func,
            "tikz": get_tikz(tikz_func_cmd, t_min, t_max)
        }

        # --- Scenario 2: The Non-Function (Sideways) ---
        a_nf = choice([-1, 1]) * choice([0.5, 0.25])
        k_nf = randint(-3, 3)
        h_nf = randint(-3, 3)
        t_min_nf, t_max_nf = get_valid_domain('sideways', a_nf, h_nf, k_nf)
        
        tikz_nf_cmd = f"({{{a_nf}*(\\x - {k_nf})^2 + {h_nf}}}, \\x)"
        rng_nf = r"(-\infty, \infty)"
        dom_nf = f"[{h_nf}, \\infty)" if a_nf > 0 else f"(-\\infty, {h_nf}]"
            
        non_func_data = {
            "is_function": "Not a function",
            "domain": dom_nf,
            "range": rng_nf,
            "tikz": get_tikz(tikz_nf_cmd, t_min_nf, t_max_nf)
        }
        
        # --- Randomize Order ---
        items = [func_data, non_func_data]
        shuffle(items)
        data_A, data_B = items[0], items[1]

        return {
            "tikz_A": data_A['tikz'],
            "is_func_A": data_A['is_function'],
            "dom_A": data_A['domain'],
            "rng_A": data_A['range'],
            
            "tikz_B": data_B['tikz'],
            "is_func_B": data_B['is_function'],
            "dom_B": data_B['domain'],
            "rng_B": data_B['range']
        }