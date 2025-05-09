from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route('/new')
def new():
    return "Nowy endpoint"

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
