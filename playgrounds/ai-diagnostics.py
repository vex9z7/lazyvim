"""Playground for diagnostics-aware AI editing.

Expected diagnostics include an undefined variable and a simple type mismatch.
Use this file to test whether an AI workflow can read editor diagnostics,
explain the problems, and propose reviewable fixes.
"""


def greet(name: str) -> str:
    return "Hello, " + user_name


print(greet(123))
