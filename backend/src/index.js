// Importando módulos necessários
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();  

const app = express();
app.use(express.json());
app.use(cors());
app.get('/', (req, res) => {
  res.send('Olá, Mundo!');
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
