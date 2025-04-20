from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)

client = MongoClient('mongodb://db:27017/')
db = client['my_dbase']

@app.route('/', methods=['GET'])
def check():
    return "Server is running", 200

@app.route('/users', methods=['GET'])
def get_users():
    try:
        users = []
        for user in db["users"].find():
            user["_id"] = str(user["_id"]) 
            users.append(user)
        return jsonify(users), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    print("Starting server...")
    app.run(host='0.0.0.0', port=3003, debug=True)
