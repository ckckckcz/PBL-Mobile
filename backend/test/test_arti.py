import pickle

with open("model/model_v2.pkl", "rb") as f:
    model = pickle.load(f)

print(type(model))
print(model.keys() if isinstance(model, dict) else "Not a dict")

for k, v in model.items():
    print(k, "->", type(v))
