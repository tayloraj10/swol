import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

cred = credentials.Certificate("firebaseCred.json")
app = firebase_admin.initialize_app(cred)
db = firestore.client()

exercises_calisthenics = 'exercises_calisthenics'
exercises_weights = 'exercises_weights'

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


def load_workout_exercises():
    # Load the data.csv file
    path = 'workout_data.csv'
    df = pd.read_csv(path)

    # Loop through the DataFrame and add each row to Firestore
    for index, row in df.iterrows():
        data = row.to_dict()
        # print(data)

        fb_data = {'category': data['category'],
                   'name': data['name'],
                   }

        add_data(exercises_weights, fb_data)


load_workout_exercises()


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


def remove_base_exercise_property():
    # Remove the base_exercise property from all documents in exercises_calisthenics
    collection_ref = db.collection(exercises_calisthenics)
    exercises = collection_ref.stream()

    for exercise in exercises:
        exercise.reference.update({'base_exercise': firestore.DELETE_FIELD})


remove_base_exercise_property()


def add_missing_queue_property(collection):
    # Add the 'queue' property to all documents in exercises_calisthenics
    collection_ref = db.collection(collection)
    exercises = collection_ref.stream()

    for exercise in exercises:
        exercise.reference.update({'queue': False})


add_missing_queue_property('workouts_calisthenics')
add_missing_queue_property('workouts_weights')
