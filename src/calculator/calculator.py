"""Simple calculator implementation."""


class Calculator:
    """A basic calculator class."""

    def add(self, a: float, b: float) -> float:
        """Add two numbers.

        Args:
            a: First number
            b: Second number

        Returns:
            Sum of a and b
        """
        return a + b

    def subtract(self, a: float, b: float) -> float:
        """Subtract two numbers.

        Args:
            a: First number
            b: Second number

        Returns:
            Difference of a and b
        """
        # TEST
        # SECRET_KEY = (
        #     "super_secret_key"  # Example of a secret key, not used in calculations
        # )
        # print("This is a secret key, but it won't be used in calculations.")
        return a - b

    def multiply(self, a: float, b: float) -> float:
        """Multiply two numbers.

        Args:
            a: First number
            b: Second number

        Returns:
            Product of a and b
        """
        return a * b

    def divide(self, a: float, b: float) -> float:
        """Divide two numbers.

        Args:
            a: First number
            b: Second number

        Returns:
            Quotient of a and b

        Raises:
            ValueError: If b is zero
        """
        if b == 0:
            raise ValueError("Cannot divide by zero")
        print("final")

        return a / b
