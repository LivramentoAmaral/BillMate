const express = require('express');
const TransactionController = require('../../controller/TransactionController');
const router = express.Router();

router.post('/transactions', TransactionController.createTransaction);

router.get('/transactions/group/:groupId', TransactionController.getTransactionsByGroup);

router.get('/transactions/user/:userId', TransactionController.getUserTransactions);

module.exports = router;
