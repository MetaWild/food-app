from fastapi import FastAPI, Request
from pydantic import BaseModel
from app.gemini import analyze_image
from app.firebase import save_meal, get_meals, upload_image_to_storage
import time
import os
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "https://food-app-zpft.onrender.com", "http://10.0.0.28:5173", "https://food-app-eta-murex.vercel.app"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class AnalyzeRequest(BaseModel):
    image: str

class SaveMealRequest(BaseModel):
    userId: str
    meal: dict

@app.post("/analyze-image")
def analyze(request: AnalyzeRequest):
    result = analyze_image(request.image)
    return result

@app.post("/save-meal")
def save_meal_api(req: SaveMealRequest):
    req.meal["timestamp"] = time.time()
    req.meal["date"] = req.meal.get("date") or datetime.now().strftime("%Y-%m-%d")

    image_base64 = req.meal.pop("image", None)
    if image_base64:
        image_url = upload_image_to_storage(image_base64, req.userId)
        req.meal["imageUrl"] = image_url

    save_meal(req.userId, req.meal)
    return {"status": "saved"}

@app.get("/meals")
def get_meal_data(userId: str, date: str = None):
    return get_meals(userId, date)

@app.get("/meals/alltime")
def get_alltime_meal_data(userId: str):
    return get_meals(userId)