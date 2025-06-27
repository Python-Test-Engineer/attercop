"""Test suite for the Calculator class.

This test file demonstrates comprehensive testing patterns including:
- Basic functionality tests
- Edge case testing
- Exception handling verification
- Parametric testing for efficiency
"""

import pytest
import sys
import os

# Add the src directory to Python path so we can import our calculator
# This handles the case where tests are run from different directories
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from calculator.calculator import Calculator


class TestCalculator:
    """Test class for Calculator functionality.

    We use a class-based approach to group related tests together and
    share setup logic through fixtures if needed.
    """

    def setup_method(self):
        """Set up a fresh Calculator instance for each test.

        This ensures that each test starts with a clean state and
        tests don't interfere with each other.
        """
        self.calc = Calculator()

    def test_add_positive_numbers(self):
        """Test addition with positive numbers."""
        result = self.calc.add(5, 3)
        assert result == 8, f"Expected 8, but got {result}"

    def test_add_negative_numbers(self):
        """Test addition with negative numbers."""
        result = self.calc.add(-5, -3)
        assert result == -8, f"Expected -8, but got {result}"

    def test_add_mixed_numbers(self):
        """Test addition with mixed positive and negative numbers."""
        result = self.calc.add(-5, 3)
        assert result == -2, f"Expected -2, but got {result}"

    def test_add_zero(self):
        """Test addition with zero (identity property)."""
        result = self.calc.add(5, 0)
        assert result == 5, f"Expected 5, but got {result}"

    def test_add_floating_point(self):
        """Test addition with floating point numbers.

        Note: We use pytest.approx() for floating point comparisons
        because of potential precision issues with float arithmetic.
        """
        result = self.calc.add(1.1, 2.2)
        assert result == pytest.approx(3.3), (
            f"Expected approximately 3.3, but got {result}"
        )

    def test_subtract_basic(self):
        """Test basic subtraction functionality."""
        result = self.calc.subtract(5, 3)
        assert result == 2, f"Expected 2, but got {result}"

    def test_subtract_negative_result(self):
        """Test subtraction that results in a negative number."""
        result = self.calc.subtract(3, 5)
        assert result == -2, f"Expected -2, but got {result}"

    def test_subtract_zero(self):
        """Test subtraction with zero."""
        result = self.calc.subtract(5, 0)
        assert result == 5, f"Expected 5, but got {result}"

    def test_multiply_positive_numbers(self):
        """Test multiplication with positive numbers."""
        result = self.calc.multiply(5, 3)
        assert result == 15, f"Expected 15, but got {result}"

    def test_multiply_by_zero(self):
        """Test multiplication by zero (should always result in zero)."""
        result = self.calc.multiply(5, 0)
        assert result == 0, f"Expected 0, but got {result}"

    def test_multiply_negative_numbers(self):
        """Test multiplication with negative numbers."""
        result = self.calc.multiply(-5, 3)
        assert result == -15, f"Expected -15, but got {result}"

        result = self.calc.multiply(-5, -3)
        assert result == 15, f"Expected 15, but got {result}"

    def test_divide_basic(self):
        """Test basic division functionality."""
        result = self.calc.divide(6, 3)
        assert result == 2, f"Expected 2, but got {result}"

    def test_divide_floating_point_result(self):
        """Test division that results in a floating point number."""
        result = self.calc.divide(5, 2)
        assert result == 2.5, f"Expected 2.5, but got {result}"

    def test_divide_by_zero_raises_error(self):
        """Test that division by zero raises a ValueError.

        This demonstrates testing for expected exceptions using pytest.raises().
        The exception handling is a critical part of robust software.
        """
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(5, 0)

    def test_divide_zero_by_number(self):
        """Test dividing zero by a non-zero number."""
        result = self.calc.divide(0, 5)
        assert result == 0, f"Expected 0, but got {result}"

    def test_divide_negative_numbers(self):
        """Test division with negative numbers."""
        result = self.calc.divide(-6, 3)
        assert result == -2, f"Expected -2, but got {result}"

        result = self.calc.divide(-6, -3)
        assert result == 2, f"Expected 2, but got {result}"

    # Parametric testing - this is a powerful pytest feature that lets us
    # run the same test with different input values efficiently
    @pytest.mark.parametrize(
        "a, b, expected",
        [
            (1, 1, 2),
            (0, 0, 0),
            (-1, 1, 0),
            (100, -50, 50),
            (0.1, 0.2, 0.3),
        ],
    )
    def test_add_parametric(self, a, b, expected):
        """Test addition with multiple parameter sets.

        This approach is more efficient than writing separate test methods
        for each case and makes it easy to add new test cases.
        """
        result = self.calc.add(a, b)
        if isinstance(expected, float):
            assert result == pytest.approx(expected)
        else:
            assert result == expected

    @pytest.mark.parametrize(
        "a, b, expected",
        [
            (6, 2, 3),
            (10, 5, 2),
            (-8, 2, -4),
            (-8, -2, 4),
            (7, 2, 3.5),
        ],
    )
    def test_divide_parametric(self, a, b, expected):
        """Test division with multiple parameter sets."""
        result = self.calc.divide(a, b)
        if isinstance(expected, float):
            assert result == pytest.approx(expected)
        else:
            assert result == expected


class TestCalculatorIntegration:
    """Integration tests that verify multiple operations work together.

    These tests ensure that the calculator can handle sequences of operations
    correctly, which is important for real-world usage scenarios.
    """

    def setup_method(self):
        """Set up calculator for integration tests."""
        self.calc = Calculator()

    def test_complex_calculation(self):
        """Test a sequence of operations together."""
        # Calculate: (5 + 3) * 2 / 4 - 1
        step1 = self.calc.add(5, 3)  # 8
        step2 = self.calc.multiply(step1, 2)  # 16
        step3 = self.calc.divide(step2, 4)  # 4
        final = self.calc.subtract(step3, 1)  # 3

        assert final == 3, f"Expected 3, but got {final}"

    def test_calculator_state_independence(self):
        """Test that calculator operations don't maintain internal state.

        This ensures that each operation is independent and doesn't
        affect subsequent operations.
        """
        result1 = self.calc.add(5, 5)
        result2 = self.calc.multiply(3, 3)
        result3 = self.calc.add(5, 5)  # Should be same as result1

        assert result1 == result3, (
            "Calculator should not maintain state between operations"
        )
        assert result1 == 10 and result2 == 9, (
            "Individual operations should work correctly"
        )


# This allows running the tests directly with: python test_calculator.py
if __name__ == "__main__":
    pytest.main([__file__, "-v"])
