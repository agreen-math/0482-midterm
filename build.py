#!/usr/bin/env python3
import subprocess
import sys
import argparse

def cleanbuild(outcomes):
    """
    Build the CheckIt bank.

    Args:
        outcomes: List of outcome names or "all"
    """
    if "all" in outcomes:
        # Generate all outcomes without force regen
        print("Generating all outcomes...")
        subprocess.run(["sage", "--python", "-m", "checkit", "generate", "-o", "ALL"], check=True)
    else:
        # Force regenerate specific outcomes
        for outcome in outcomes:
            print(f"Force regenerating outcome {outcome}...")
            subprocess.run(["sage", "--python", "-m", "checkit", "generate", "-r", "-o", outcome], check=True)

    # Build the viewer
    print("Building viewer...")
    subprocess.run(["sage", "--python", "-m", "checkit", "viewer"], check=True)
    print("Done!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Clean build CheckIt outcomes")
    parser.add_argument("outcomes", nargs="+", help="Outcome names or 'all'")
    args = parser.parse_args()
    cleanbuild(args.outcomes)