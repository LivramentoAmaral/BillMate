const express = require('express');
const TransactionController = require('../../controller/TransactionController');
const authMiddleware = require('../../middlewares/authMiddleware');

const router = express.Router();

router.post('/', authMiddleware, TransactionController.createTransaction);
router.get('/group/:groupId', authMiddleware, TransactionController.getTransactionsByGroup);
router.get('/user/:userId', authMiddleware, TransactionController.getUserTransactions);

module.exports = router;
