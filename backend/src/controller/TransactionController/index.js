const Transaction = require('../../models/Transaction');

module.exports = {
  async createTransaction(req, res) {
    const { userId, groupId, type, value, date } = req.body;

    const transaction = await Transaction.create({ userId, groupId, type, value, date });
    res.status(201).json(transaction);
  },

  async getTransactionsByGroup(req, res) {
    const { groupId } = req.params;
    const transactions = await Transaction.find({ groupId }).populate('userId');

    res.json(transactions);
  },

  async getUserTransactions(req, res) {
    const { userId } = req.params;
    const transactions = await Transaction.find({ userId });

    res.json(transactions);
  },
};
