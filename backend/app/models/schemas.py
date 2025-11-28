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
    orb_n_features: Any
    vocab_size: Any
    kmeans_n_clusters: int
    kmeans_input_features: int
    kmeans_output_features: int
    scaler_input_features: int
    xgb_model_type: str
    xgb_n_classes: Any


class ProbabilitiesPerClass(BaseModel):
    """Schema for prediction probabilities per class"""
    Sampah_Organik: Optional[float] = Field(None, alias="Sampah Organik")
    Sampah_Anorganik: Optional[float] = Field(None, alias="Sampah Anorganik")
    Sampah_B3: Any = Field(None, alias="Sampah B3")

    class Config:
        populate_by_name = True


class ModelInfo(BaseModel):
    """Schema for detailed model information"""
    confidenceSource: str
    pipeline: ModelPipelineInfo
    modelComponents: ModelComponents
    probabilitiesPerClass: ProbabilitiesPerClass
    _note: str


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
