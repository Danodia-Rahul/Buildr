from typing import List

import numpy as np
import onnxruntime as ort
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Fertilizer Recommendation API")

SOIL_TYPE_MAP = {
    "Black": 0,
    "Clayey": 1,
    "Loamy": 2,
    "Red": 3,
    "Sandy": 4,
}

CROP_TYPE_MAP = {
    "Barley": 0,
    "Cotton": 1,
    "Ground Nuts": 2,
    "Maize": 3,
    "Millets": 4,
    "Oil seeds": 5,
    "Paddy": 6,
    "Pulses": 7,
    "Sugarcane": 8,
    "Tobacco": 9,
    "Wheat": 10,
}

FERTILIZER_MAP = {
    0: "10-26-26",
    1: "14-35-14",
    2: "17-17-17",
    3: "20-20",
    4: "28-28",
    5: "DAP",
    6: "Urea",
}

_session, _model_input_name = None, None


class PredictionInput(BaseModel):
    Temperature: float
    Humidity: float
    Moisture: float
    Soil_Type: str
    Crop_Type: str
    Nitrogen: float
    Potassium: float
    Phosphorous: float


def load_model():
    global _session, _model_input_name

    if not _session:
        _session = ort.InferenceSession(
            "model.onnx", providers=["CPUExecutionProvider"]
        )
        _model_input_name = _session.get_inputs()[0].name

    return _session, _model_input_name


def build_input(data: dict) -> PredictionInput:
    obj = PredictionInput(
        Temperature=data["Temperature"],
        Humidity=data["Humidity"],
        Moisture=data["Moisture"],
        Soil_Type=data["Soil_Type"],
        Crop_Type=data["Crop_Type"],
        Nitrogen=data["Nitrogen"],
        Potassium=data["Potassium"],
        Phosphorous=data["Phosphorous"],
    )

    return obj


def build_feature_array(data: PredictionInput) -> np.ndarray:
    try:
        soil_encoded = SOIL_TYPE_MAP[data.Soil_Type]
        crop_encoded = CROP_TYPE_MAP[data.Crop_Type]
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Invalid category value: {str(e)}")

    features = [
        data.Temperature,
        data.Humidity,
        data.Moisture,
        soil_encoded,
        crop_encoded,
        data.Nitrogen,
        data.Potassium,
        data.Phosphorous,
    ]

    return np.array([features], dtype=np.float32)


def get_top_predictions(probabilities: np.ndarray, top_k: int = 3) -> List[str]:
    sorted_indices = np.argsort(probabilities, axis=1)[:, ::-1][:, :top_k]
    top_classes = sorted_indices[0]

    return [FERTILIZER_MAP[int(idx)] for idx in top_classes]


@app.get("/")
def home():
    return {"status": "ok"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict")
def predict(data: PredictionInput):
    try:
        input_array = build_feature_array(data)
        session, MODEL_INPUT_NAME = load_model()

        outputs = session.run(None, {MODEL_INPUT_NAME: input_array})

        predictions = get_top_predictions(outputs)

        return {
            "top_3_recommendations": predictions,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
