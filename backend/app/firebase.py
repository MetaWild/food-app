import firebase_admin
import os
from firebase_admin import credentials, firestore
import json

firebase_json = os.getenv("FIREBASE_CONFIG_JSON")
if not firebase_json:
    raise RuntimeError("FIREBASE_CONFIG_JSON not set")

cred_dict = json.loads(firebase_json)
cred = credentials.Certificate(cred_dict)
firebase_admin.initialize_app(cred)
db = firestore.client()

def save_meal(user_id, meal_data):
    doc_ref = db.collection("users").document(user_id).collection("meals").document()
    doc_ref.set(meal_data)

def get_meals(user_id, date=None):
    query = db.collection("users").document(user_id).collection("meals")
    if date:
        query = query.where("date", "==", date)
    query = query.order_by("timestamp", direction=firestore.Query.DESCENDING)
    return [doc.to_dict() for doc in query.stream()]