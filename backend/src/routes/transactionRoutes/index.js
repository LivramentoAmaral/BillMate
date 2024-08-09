const express = require('express');
const TransactionController = require('../../controller/TransactionController');
const router = express.Router();

router.post('/', TransactionController.createTransaction);

router.get('/group/:groupId', TransactionController.getTransactionsByGroup);

router.get('/user/:userId', TransactionController.getUserTransactions);

module.exports = router;
