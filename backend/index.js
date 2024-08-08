const express = require('express');
const app = express();

// Middleware para lidar com JSON
app.use(express.json());

// Rota básica
app.get('/', (req, res) => {
    res.send('Olá, Mundo!');
});

// Iniciando o servidor
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
