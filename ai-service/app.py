import io

from fastapi import FastAPI, File, UploadFile
from PIL import Image
from ultralytics import YOLO


app = FastAPI(title="Microgreens AI Service")

# Load the trained model once at startup.
model = YOLO("model/best.pt")


@app.get("/")
def home():
    return {"message": "AI service is running"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")

    results = model(image)
    result = results[0]

    predictions = []
    for box in result.boxes:
        class_id = int(box.cls[0])
        predictions.append(result.names[class_id])

    return {
        "filename": file.filename,
        "predictions": predictions,
    }
