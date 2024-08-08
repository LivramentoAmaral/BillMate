// Importando módulos necessários
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();  

const app = express();

// Conexão com o banco de dados
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,

}).then(() => {
  console.log('Conectado ao banco de dados!');
}
).catch((err) => {
  console.log(err);
});


app.use(express.json());
app.use(cors());
app.get('/', (req, res) => {
  res.send('Olá, Mundo!');
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
