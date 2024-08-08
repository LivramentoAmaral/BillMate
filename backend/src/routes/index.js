const express = require('express');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const groupRoutes = require('./groupRoutes');
const transactionRoutes = require('./transactionRoutes');

const router = express.Router();


router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/groups', groupRoutes);
router.use('/transactions', transactionRoutes);

module.exports = router;
