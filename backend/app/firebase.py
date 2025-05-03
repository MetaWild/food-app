import firebase_admin
import os
from firebase_admin import credentials, firestore, storage
import time
import base64
import json

firebase_json = os.getenv("FIREBASE_CONFIG_JSON")
if not firebase_json:
    raise RuntimeError("FIREBASE_CONFIG_JSON not set")

cred_dict = json.loads(firebase_json)
cred = credentials.Certificate(cred_dict)
firebase_admin.initialize_app(cred, {
    'storageBucket': cred_dict.get("project_id") + ".appspot.com"
})

db = firestore.client()
bucket = storage.bucket()

def save_meal(user_id, meal_data):
    doc_ref = db.collection("users").document(user_id).collection("meals").document()
    doc_ref.set(meal_data)

def get_meals(user_id, date=None):
    query = db.collection("users").document(user_id).collection("meals")
    if date:
        query = query.where("date", "==", date)
    query = query.order_by("timestamp", direction=firestore.Query.DESCENDING)
    return [doc.to_dict() for doc in query.stream()]

def upload_image_to_storage(base64_str, user_id):
    header, encoded = base64_str.split(",", 1)
    image_data = base64.b64decode(encoded)
    filename = f"{user_id}_{int(time.time())}.jpg"

    blob = bucket.blob(f"meal_images/{filename}")
    blob.upload_from_string(image_data, content_type='image/jpeg')
    blob.make_public()

    return blob.public_url