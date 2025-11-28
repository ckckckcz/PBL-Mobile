import joblib
import numpy as np
from PIL import Image

model = joblib.load('model/model_v2.pkl')
print('=== MODEL STRUCTURE ===')
print('Model keys:', list(model.keys()))
print('vocab_size:', model.get('vocab_size', 'N/A'))
print('orb_n_features:', model.get('orb_n_features', 'N/A'))
print('KMeans n_clusters:', model['kmeans_model'].n_clusters)
print('KMeans n_features_in_:', model['kmeans_model'].n_features_in_)
print('Scaler n_features_in_:', model['scaler_model'].n_features_in_)

# Test dengan berbagai ukuran input
print('\n=== TESTING KMEANS INPUT ===')
kmeans = model['kmeans_model']

# Test 1: Input 32 features
try:
    test_32 = np.random.randn(1, 32)
    output_32 = kmeans.transform(test_32)
    print(f'✓ KMeans.transform(32 features) → output shape: {output_32.shape}')
except Exception as e:
    print(f'✗ KMeans.transform(32 features) error: {e}')

# Test 2: Input 500 features
try:
    test_500 = np.random.randn(1, 500)
    output_500 = kmeans.transform(test_500)
    print(f'✓ KMeans.transform(500 features) → output shape: {output_500.shape}')
except Exception as e:
    print(f'✗ KMeans.transform(500 features) error: {e}')

# Test 3: Check what actually works for StandardScaler
print('\n=== STANDARDSCALER INPUT ===')
scaler = model['scaler_model']
print(f'Scaler expects {scaler.n_features_in_} features')

print(f'\nKMeans cluster centers shape: {kmeans.cluster_centers_.shape}')
print(f'This means KMeans was trained with input of shape: (n_samples, {kmeans.cluster_centers_.shape[1]})')
