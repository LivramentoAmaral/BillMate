const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  groupId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Group', 
    required: true 
  },
  type: { 
    type: String, 
    enum: ['Fixo', 'Variável'] ,default: 'Variável', 
    required: true 
  },
  category: { 
    type: String, 
    required: true 
  },
  value: { 
    type: Number, 
    required: true 
  },
  date: { 
    type: Date, 
    required: true 
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Transaction', TransactionSchema);
