import pickle
import joblib
from pathlib import Path

model_path = Path("model/model_terbaru_v2.pkl")

print("[CHECK] Validating model file...")
print(f"[CHECK] Path: {model_path}")
print(f"[CHECK] Exists: {model_path.exists()}")
print(f"[CHECK] Size: {model_path.stat().st_size} bytes\n")

# Check file magic bytes
with open(model_path, 'rb') as f:
    header = f.read(16)
    print(f"[CHECK] File header (hex): {header.hex()}")
    print(f"[CHECK] File header: {header}\n")

# Attempt 1: Standard pickle
print("[ATTEMPT 1] Standard pickle.load()")
try:
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    print(f"✓ SUCCESS! Model type: {type(model)}")
    print(f"  Model: {model}")
except Exception as e:
    print(f"✗ FAILED: {e}\n")

# Attempt 2: Pickle with latin1
print("[ATTEMPT 2] pickle.load() with encoding='latin1'")
try:
    with open(model_path, 'rb') as f:
        model = pickle.load(f, encoding='latin1')
    print(f"✓ SUCCESS! Model type: {type(model)}")
except Exception as e:
    print(f"✗ FAILED: {e}\n")

# Attempt 3: Joblib
print("[ATTEMPT 3] joblib.load()")
try:
    model = joblib.load(model_path)
    print(f"✓ SUCCESS! Model type: {type(model)}")
    print(f"  Model: {model}")
except Exception as e:
    print(f"✗ FAILED: {e}\n")

print("\n[RESULT] File is likely corrupt or not a Python pickle/joblib file")
