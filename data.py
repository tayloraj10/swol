import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

cred = credentials.Certificate("firebaseCred.json")
app = firebase_admin.initialize_app(cred)
db = firestore.client()

exercises_calisthenics = 'exercises_calisthenics'

# Load Calisthenics Exercises


def add_data(collection_name, data):
    # Function to add data to Firestore
    try:
        # Reference to the collection
        collection_ref = db.collection(collection_name)

        # Adding data to Firestore
        collection_ref.add(data)
    except Exception as e:
        print(f"An error occurred: {e}")


def load_calisthenics_exercises():
    # Load the data.csv file
    path = 'data.csv'
    df = pd.read_csv(path)

    # Loop through the DataFrame and add each row to Firestore
    for index, row in df.iterrows():
        data = row.to_dict()
        # print(data)

        fb_data = {'category': data['Category'],
                   'name': data['Exercise'],
                   'next_progressions': [],
                   }
        if data['Base Exercise']:
            fb_data['base_exercise'] = True

        add_data(exercises_calisthenics, fb_data)

load_calisthenics_exercises()


def clear_calisthenics_exercises():
    # Clear the exercises_calisthenics collection
    collection_ref = db.collection(exercises_calisthenics)
    exercises = collection_ref.stream()

    for exercise in exercises:
        exercise.reference.delete()

# clear_calisthenics_exercises()