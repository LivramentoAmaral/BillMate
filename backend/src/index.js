// Importando módulos necessários
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();  

const routes = require('./routes/index'); // Importando as rotas
const errorHandler = require('./middlewares/errorHandler'); // Importando o middleware de tratamento de erros

const app = express();

// Conexão com o banco de dados
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,

})
.then(() => {
  console.log('Conectado ao MongoDB!');
})
.catch((err) => {
  console.error('Erro ao conectar ao MongoDB:', err);
});

// Aplicando middlewares
app.use(express.json());
app.use(cors());

// Definindo as rotas
app.use('/api', routes);

// Middleware de tratamento de erros
app.use(errorHandler);

// Rota inicial
// app.get('/', (req, res) => {
//   res.send('Olá, Mundo!');
// });

// Configurando a porta e iniciando o servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
