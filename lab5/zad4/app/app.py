from flask import Flask
import os

app = Flask(__name__)

DATA_DIR = '/app/data/logs.txt'

@app.route('/')
def hej():
    message = "witaj na serwerze"

    with open(DATA_DIR, 'a') as f:
        f.write(message)

    return message

if __name__ == '__main__':
    port = int(os.getenv('PORT'))
    app.run(host='0.0.0.0', port=port)