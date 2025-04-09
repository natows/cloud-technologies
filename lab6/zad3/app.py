from flask import Flask
import pymysql

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from backend"

@app.route("/db")
def db_check():
    try:
        conn = pymysql.connect(
            host="193.168.100.2",
            user="user",
            password="pass",
            database="appdb"
        )
        conn.close()
        return "DB connection successful"
    except Exception as e:
        return f"DB connection failed: {e}"

if __name__ == "__main__":
    app.run(host="192.168.100.2", port=80)