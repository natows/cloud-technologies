from flask import Flask
import requests

app = Flask(__name__)

PORT = 3000

@app.route('/')
def index():
    try:
        print("Próba połączenia z service-b...")
        response = requests.get('http://service-b:5000')
        print(f"Odpowiedź z service-b: Tekst={response.text}")
        return f'Response from service-a. Received from service-b: {response.text}'
    except Exception as e:
        error_message = f'Nie udalo sie polaczyc z mikroserwisem b: {str(e)}'
        print(error_message)
        return error_message

if __name__ == '__main__':
    app.run(host='0.0.0.0', port = PORT, debug=True)