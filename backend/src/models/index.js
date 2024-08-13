const mongoose = require('mongoose');
const { Schema } = mongoose;

/* Dessa forma a esquematização da modelagem de dados 
fica “ideal” para o banco de dados MongoDB, coisa que 
no meu ver não é boa, pois se por algum acaso for preciso 
trocar vai ter que modelar tudo de novo. 
*/


// Model de Usuário
const usuarioSchema = new Schema({
    nome: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    senha: { type: String, required: true },
    tipoConta: { type: String, enum: ['Simples', 'Prime'], required: true },
    rendaFixa: { type: Number, required: true },  // Renda fixa como atributo
    gruposCriados: [{ type: Schema.Types.ObjectId, ref: 'Grupo' }] // Relacionamento 1:N com Grupo
});

usuarioSchema.pre('save', async function(next) {
    if (this.isModified('password')) {
      this.password = await bcrypt.hash(this.password, 8);
    }
    next();
});
  
usuarioSchema.methods.comparePassword = function(password) {
    return bcrypt.compare(password, this.password);
};


// Model de Grupo
const grupoSchema = new Schema({
    nome: { type: String, required: true },
    criador: { type: Schema.Types.ObjectId, ref: 'Usuario', required: true }, // Relacionamento 1:N com Usuário
    membros: [{ type: Schema.Types.ObjectId, ref: 'Usuario' }] // Relacionamento N:N com Usuário (membros)
});
  
const Grupo = mongoose.model('Grupo', grupoSchema);


// Gasto ou Transação
const gastoSchema = new Schema({
    usuario: { type: Schema.Types.ObjectId, ref: 'Usuario', required: true }, // Relacionamento 1:N com Usuário
    grupo: { type: Schema.Types.ObjectId, ref: 'Grupo', required: true }, // Relacionamento 1:N com Grupo
    valor: { type: Number, required: true },
    tipoGasto: { type: String, enum: ['Fixo', 'Variável'], required: true },
    categoria: { type: String, required: true },
    data: { type: Date, default: Date.now, required: true }
});
  
const Gasto = mongoose.model('Gasto', gastoSchema);
  