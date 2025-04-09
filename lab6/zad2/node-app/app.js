const express = require('express');
const mysql = require('mysql2/promise'); 

const app = express();
const PORT = 3000;

app.get('/', async (req, res) => {
  try {
    const connection = await mysql.createConnection({
      host: 'db',
      port: 3306,
      user: 'user',
      password: 'userpass',
      database: 'testdb'
    });

    console.log('Połączono z bazą danych!');
    const [rows] = await connection.execute('SELECT * FROM test');
    await connection.end();
    
    console.log('Pobrane dane:', rows); 
    res.send(`Pobrane dane: ${JSON.stringify(rows)}`);
  } catch (err) {
    console.error('Błąd połączenia:', err);
    res.status(500).send('Błąd połączenia z bazą danych: ' + err.message);
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Serwer działa na porcie ${PORT}`);
});