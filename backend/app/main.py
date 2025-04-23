from fastapi import FastAPI, Request
from pydantic import BaseModel
from app.gemini import analyze_image
from app.firebase import save_meal, get_meals
import time
import os
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

# CORS for local frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "https://food-app-zpft.onrender.com"],
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
    # Add timestamp and human-readable date
    req.meal["timestamp"] = time.time()
    req.meal["date"] = datetime.now().strftime("%Y-%m-%d")

    save_meal(req.userId, req.meal)
    return {"status": "saved"}

@app.get("/meals")
def get_meal_data(userId: str, date: str = None):
    return get_meals(userId, date)