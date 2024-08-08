const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  groupId: { type: mongoose.Schema.Types.ObjectId, ref: 'Group' },
  type: { type: String, enum: ['Fixo', 'Variável'] },
  value: Number,
  date: Date,
}, {
  timestamps: true,
});

module.exports = mongoose.model('Transaction', TransactionSchema);
