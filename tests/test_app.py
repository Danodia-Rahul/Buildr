import numpy as np
import pytest
from fastapi.testclient import TestClient

from app.app import (
    PredictionInput,
    app,
    build_feature_array,
    build_input,
    get_top_predictions,
)

sample_input = {
    "Temperature": 20,
    "Humidity": 20,
    "Moisture": 20,
    "Soil_Type": "Black",
    "Crop_Type": "Cotton",
    "Nitrogen": 20,
    "Potassium": 20,
    "Phosphorous": 20,
}


def test_build_input():
    got = build_input(sample_input.copy())
    want = PredictionInput(
        Temperature=20,
        Humidity=20,
        Moisture=20,
        Soil_Type="Black",
        Crop_Type="Cotton",
        Nitrogen=20,
        Potassium=20,
        Phosphorous=20,
    )

    assert got.model_dump() == want.model_dump()


def test_build_feature_array():
    got = sample_input.copy()
    want = np.array([[20, 20, 20, 0, 1, 20, 20, 20]], dtype=np.float32)

    assert np.array_equal(build_feature_array(build_input(got)), want)


def test_get_top_predictions():
    inp = np.array([[0.1, 0.2, 0.3, 0.1, 0.1, 0.05, 0.15]], dtype=np.float32)
    got = get_top_predictions(inp)
    want = [
        "17-17-17",
        "14-35-14",
        "Urea",
    ]

    assert got == want


@pytest.fixture
def client():
    return TestClient(app)


def test_home(client):
    response = client.get("/")
    assert response.status_code == 200


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
