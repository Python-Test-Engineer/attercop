print("Hello from custom.py")  # Stdout only printed when Failed

test_value = 2 + 2
print(f"Test value: {test_value}")  # This will be printed if no error occurs
if test_value != 4:
    raise ValueError("Test value is not 4, something went wrong!")
