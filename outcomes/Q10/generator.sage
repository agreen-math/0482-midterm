from sage.all import *
from random import randint, choice

class Generator(BaseGenerator):
    def data(self):
        # Context: A vehicle rental
        vehicle = choice(['rental car', 'moving truck', 'cargo van'])
        person = choice(['Allie', 'Bob', 'Charlie', 'Dana', 'Evan'])
        
        # 1. Set the Rates
        # Base fee (daily rate): Integer usually $25 - $60
        base_fee = randint(25, 60)
        
        # Mile rate: $0.20 to $0.85
        # Pick from a list of "nice" cents to look realistic
        rate_cents = choice([25, 30, 35, 40, 42, 45, 48, 50, 55, 60, 75])
        rate = rate_cents / 100.0
        
        # 2. Pick the Answer (Miles driven)
        # Keep it reasonable (50 to 300 miles)
        miles = randint(50, 300)
        
        # 3. Calculate the Total Budget required
        # Total = Base + (Rate * Miles)
        # We perform this calc to determine what the problem states as "Total Cash"
        variable_cost = rate * miles
        
        # To ensure the "Total" looks like a normal money amount (max 2 decimals),
        # we round/format. Since we picked finite decimals, it should be exact,
        # but floating point math can be tricky.
        total_budget = float(base_fee + variable_cost)
        
        # --- Formatting Strings ---
        
        # Money formatting helper
        def to_money(val):
            return f"{val:.2f}"
            
        base_str = to_money(base_fee)
        rate_str = to_money(rate)
        total_str = to_money(total_budget)
        
        # --- Solution Step Values ---
        
        # Step 1: Subtract Base Fee
        # Remainder = Total - Base
        remainder = total_budget - base_fee
        remainder_str = to_money(remainder)
        
        # Step 2: Divide by Rate
        # Answer is already 'miles' variable
        
        # Solution String Construction
        # Matches the handwritten style: "105 - 45 = 60"
        step1 = f"{total_str} - {base_str} = {remainder_str}"
        
        # Matches handwritten style: "60 / 0.48 = 125"
        # Using fraction display for division
        step2 = f"\\frac{{{remainder_str}}}{{{rate_str}}} = {miles}"
        
        final_answer = f"{miles} \\text{{ miles}}"

        return {
            "vehicle": vehicle,
            "person": person,
            "base_str": base_str,
            "rate_str": rate_str,
            "total_str": total_str,
            "step1": step1,
            "step2": step2,
            "final": final_answer
        }