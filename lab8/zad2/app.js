const express = require("express");
const redis = require("redis");
const app = express();
app.use(express.json());
const PORT = 3000;


const client = redis.createClient({
    url: 'redis://redis:6379'
})

client.on('error', (err) => {
    console.error(`redis error:, ${err}`)
})

async function startServer() {
    try {
        await client.connect();
        console.log('Connected to Redis');
        
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    } catch (error) {
        console.error(`Failed to connect to Redis: ${error}`);
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
startServer();