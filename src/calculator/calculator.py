"""Simple calculator implementation."""

# TEST
# secret_key = "super_secret_key"
# SECRET_API = "https://api.example.com/secret"
# print(f"This is a secret_key {secret_key}, but it won't be used in calculations.")
# print(f"This is a SECRET_API {SECRET_API}, but it won't be used in calculations.")


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


if __name__ == "__main__":
    # Example usage
    calc = Calculator()
    print("Addition:", calc.add(5, 3))
    print("Subtraction:", calc.subtract(5, 3))
    print("Multiplication:", calc.multiply(5, 3))
    try:
        print("Division:", calc.divide(5, 0))  # This will raise an error
    except ValueError as e:
        print(e)
