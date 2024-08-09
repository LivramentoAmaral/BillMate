const Transaction = require('../../models/Transaction');
const Group = require('../../models/Group');

module.exports = {
  async createTransaction(req, res) {
    const { userId, groupId, type, value, date } = req.body;
    try {
      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: 'Grupo não encontrado' });
      }
      if (!group.owner === userId) {
        return res.status(403).json({ error: 'Usuário não é membro do grupo' });
      }
      const transaction = await Transaction.create({ userId, groupId, type, value, date });

      res.status(201).json(transaction);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao criar transação' });
    }
  },
  async getTransactionsByGroup(req, res) {
    const { groupId } = req.params;

    try {
      const transactions = await Transaction.find({ groupId }).populate('userId');

      if (!transactions.length) {
        return res.status(404).json({ error: 'Nenhuma transação encontrada para este grupo' });
      }

      res.json(transactions);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao buscar transações do grupo' });
    }
  },
  async getUserTransactions(req, res) {
    const { userId } = req.params;

    try {
      const transactions = await Transaction.find({ userId });

      if (!transactions.length) {
        return res.status(404).json({ error: 'Nenhuma transação encontrada para este usuário' });
      }

      res.json(transactions);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao buscar transações do usuário' });
    }
  },
};
