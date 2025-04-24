const express = require("express");
const redis = require("redis");
const { Pool } = require("pg");
const app = express();
app.use(express.json());
const PORT = 3000;


const client = redis.createClient({
    url: 'redis://redis:6379'
});

const pgPool = new Pool({
    user: 'postgres',    
    host: 'postgres',      
    database: 'userdb',     
    password: 'postgres123', 
    port: 5432,
})

client.on('error', (err) => {
    console.error(`redis error:, ${err}`)
})

async function startServer() {
    try {
        await client.connect();
        console.log('Connected to Redis');

        try {
            const pgClient = await pgPool.connect();
            await pgClient.query('CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, login VARCHAR(50) NOT NULL, password VARCHAR(50) NOT NULL)');
            pgClient.release();
            console.log('Connected to PostgreSQL and ensured users table exists');
        

            app.listen(PORT, () => {
                console.log(`Server running on port ${PORT}`);
            });
        } catch (pgError) {
            console.error(`Failed to connect to PostgreSQL: ${pgError}`);
            process.exit(1);
        }
    } catch (redisError) {
        console.error(`Failed to connect to Redis: ${redisError}`);
        process.exit(1);
    }
}


app.get('/', (req, res) => {
    res.send("server dziala, mozesz pobrc wiadomosci");
})

app.get('/message', async(req, res) => {
    try {
        const keys = await client.keys('*');
        const messages = [];
        for (const key of keys) {
            const value = await client.get(key);
            messages.push({ key, value });
        }
        res.json(messages);
    }
    catch (error) {
        res.status(500).json({ error: 'nie udalo sie pobrac wiadomosci' });
    }
})

app.post('/message', async(req, res) => {
    try {
        const {key, value} = req.body;
        await client.set(key,value);
        res.status(201).json({ message: `wiadomosc dodana` });

    }
    catch (error) {
        res.status(500).json({ error: 'nie udalo sie dodac wiadomosci' });
    }
})

app.get('/users', async (req, res) => {
    try {
        const pgClient = await pgPool.connect();
        const result = await pgClient.query('SELECT * FROM users');
        pgClient.release();
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: 'nie udalo sie pobrac uzytkownikow' });
    }
})
app.post('/users', async (req, res) => {
    try {
        const { login, password } = req.body;
        const pgClient = await pgPool.connect();
        await pgClient.query('INSERT INTO users (login, password) VALUES ($1, $2)', [login, password]);
        pgClient.release();
        res.status(201).json({ message: 'uzytkownik dodany' });
    } catch (error) {
        res.status(500).json({ error: 'nie udalo sie dodac uzytkownika' });
    }
})
startServer();

