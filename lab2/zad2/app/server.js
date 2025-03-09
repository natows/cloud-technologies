const express = require('express');
const app = express();
const port = 8080;
app.get('/', (req, res) => {
  res.json({ date: new Date().toLocaleString() });
});
app.listen(port, () => {
  console.log('Server running on http://localhost:' + port + '/');
});
