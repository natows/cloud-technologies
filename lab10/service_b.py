from flask import Flask, jsonify
import psycopg2
import time

app = Flask(__name__)

PORT = 5000

# Funkcja do nawiązania połączenia z bazą danych
def get_db_connection():
    # Próbuj połączyć się z bazą danych, ponawiając próby w razie niepowodzenia
    retries = 5
    while retries > 0:
        try:
            conn = psycopg2.connect(
                host='postgres',          # Nazwa serwisu bazy danych w Kubernetes
                database='postgres',      # Nazwa bazy danych
                user='postgres',          # Nazwa użytkownika
                password='postgres',      # Hasło
                connect_timeout=5
            )
            print("Połączono z bazą danych!")
            return conn
        except Exception as e:
            print(f"Błąd połączenia z bazą danych: {e}")
            retries -= 1
            if retries > 0:
                print(f"Ponowna próba za 5 sekund... Pozostało prób: {retries}")
                time.sleep(5)
    return None

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        if conn:
            # Utwórz kursor
            cur = conn.cursor()
            
            # Utwórz tabelę, jeśli nie istnieje
            cur.execute("CREATE TABLE IF NOT EXISTS messages (id SERIAL PRIMARY KEY, content TEXT)")
            
            # Wstaw wiadomość testową
            message = "odpowiedz z mikroserwisu b (z bazy danych)"
            cur.execute("INSERT INTO messages (content) VALUES (%s) RETURNING id", (message,))
            message_id = cur.fetchone()[0]
            
            # Zatwierdź transakcję
            conn.commit()
            
            # Pobierz wiadomość
            cur.execute("SELECT content FROM messages WHERE id = %s", (message_id,))
            result = cur.fetchone()[0]
            
            # Zamknij połączenie
            cur.close()
            conn.close()
            
            return result
        else:
            return "Nie udało się połączyć z bazą danych"
    except Exception as e:
        return f"Błąd: {str(e)}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=True)