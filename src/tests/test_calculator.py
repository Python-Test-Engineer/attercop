"""Tests for the calculator module."""

# type: ignore
import pytest

from calculator import Calculator


class TestCalculator:
    """Test cases for Calculator class."""

    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()

    def test_add(self):
        """Test addition functionality."""
        assert self.calc.add(2, 3) == 5
        assert self.calc.add(-1, 1) == 0
        assert self.calc.add(0.1, 0.2) == pytest.approx(0.3)

    def test_subtract(self):
        """Test subtraction functionality."""
        assert self.calc.subtract(5, 3) == 2
        assert self.calc.subtract(1, 1) == 0
        assert self.calc.subtract(-1, -1) == 0

    def test_multiply(self):
        """Test multiplication functionality."""
        assert self.calc.multiply(2, 3) == 6
        assert self.calc.multiply(-2, 3) == -6
        assert self.calc.multiply(0, 5) == 0

    def test_divide(self):
        """Test division functionality."""
        assert self.calc.divide(6, 2) == 3
        assert self.calc.divide(1, 2) == 0.5
        assert self.calc.divide(-6, 2) == -3

    def test_divide_by_zero(self):
        """Test division by zero raises ValueError."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(5, 0)
