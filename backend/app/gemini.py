import google.generativeai as genai
import os
from dotenv import load_dotenv
import base64
import json
import re

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

model = genai.GenerativeModel("gemini-2.0-flash")

def analyze_image(base64_image):
    image_bytes = base64.b64decode(base64_image.split(",")[1])
    
    prompt = (
        "You are a food and nutrition assistant. The user is uploading an image of a meal. "
        "Please analyze the meal and respond in the following JSON format:\n\n"
        "{\n"
        "  \"title\": \"Meal name\",\n"
        "  \"ingredients\": [\"ingredient1\", \"ingredient2\", ...],\n"
        "  \"nutrition\": [\n"
        "    {\"name\": \"Chicken breast\", \"calories\": 165, \"protein\": 31, \"carbs\": 0, \"fat\": 3.6},\n"
        "    {\"name\": \"Lettuce\", \"calories\": 15, \"protein\": 1, \"carbs\": 2, \"fat\": 0}\n"
        "  ],\n"
        "  \"total\": {\"calories\": 319, \"protein\": 33, \"carbs\": 6, \"fat\": 17.6}\n"
        "}"
    )

    try:
        response = model.generate_content([
            prompt,
            {
                "mime_type": "image/jpeg",
                "data": image_bytes
            }
        ])

        print("\n--- Gemini Raw Response ---\n")
        print(response.text)
        print("\n---------------------------\n")

        result_text = response.text.strip()

        # 🧠 Extract the first full JSON object in the response
        json_match = re.search(r"\{.*\}", result_text, re.DOTALL)
        if not json_match:
            raise ValueError("No JSON object found in Gemini response.")

        json_data = json.loads(json_match.group())
        return json_data

    except Exception as e:
        print("Gemini error:", e)
        return {"error": "Failed to analyze image or parse response."}