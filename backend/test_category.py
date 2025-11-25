import numpy as np
from app.main import get_waste_category

test_cases = [
    "Sampah Organik",
    "Sampah Anorganik", 
    "Sampah B3",
    "Unknown"
]

for test in test_cases:
    try:
        result = get_waste_category(test)
        print(f"✓ {test} → {result['category']}")
    except Exception as e:
        print(f"✗ {test} → ERROR: {e}")
