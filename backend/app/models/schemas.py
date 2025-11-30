"""
Pydantic schemas for API request/response validation
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional


class TipItem(BaseModel):
    """Schema for waste tip item"""
    title: str
    color: str


class ModelPipelineInfo(BaseModel):
    """Schema for model pipeline information"""
    step_1: str
    step_2: str
    step_3: str
    step_4: str
    step_5: str
    step_6: str
    step_7: str
    step_8: str


class ModelComponents(BaseModel):
    """Schema for model components information"""
    xgb_model_type: str
    scaler_type: str
    label_encoder_type: str
    n_classes: int
    classes: List[str]
    waste_map: Dict[str, str]
    threshold: float
    # Make these optional since they may not be used in this model
    orb_n_features: Optional[Any] = None
    vocab_size: Optional[Any] = None
    kmeans_n_clusters: Optional[int] = None
    kmeans_input_features: Optional[int] = None
    kmeans_output_features: Optional[int] = None
    scaler_input_features: Optional[int] = None
    xgb_n_classes: Optional[Any] = None

    class Config:
        extra = "allow"  # Allow extra fields not defined in schema


class ProbabilitiesPerClass(BaseModel):
    """Schema for prediction probabilities per class"""

    class Config:
        extra = "allow"  # Allow any class name as key


class ModelInfo(BaseModel):
    """Schema for detailed model information"""
    confidenceSource: str
    pipeline: Dict[str, str]  # Changed from ModelPipelineInfo to Dict for flexibility
    modelComponents: ModelComponents
    probabilitiesPerClass: Optional[Dict[str, Any]] = None

    class Config:
        extra = "allow"  # Allow extra fields


class PredictionData(BaseModel):
    """Schema for prediction data"""
    wasteType: str
    category: str
    confidence: float
    tips: List[TipItem]
    description: str
    modelInfo: ModelInfo


class PredictionResponse(BaseModel):
    """Schema for prediction API response"""
    success: bool
    data: PredictionData


class HealthCheckResponse(BaseModel):
    """Schema for health check response"""
    status: str
    model_loaded: bool


class RootResponse(BaseModel):
    """Schema for root endpoint response"""
    message: str
    model_loaded: bool
    endpoints: Dict[str, str]
    server: str
    version: str


class TestResponse(BaseModel):
    """Schema for test endpoint response"""
    success: bool
    message: str
    model_loaded: bool
    timestamp: str


class UserResponse(BaseModel):
    """Schema for user list response"""
    success: bool
    data: List[Dict[str, Any]]


class ErrorResponse(BaseModel):
    """Schema for error response"""
    detail: str