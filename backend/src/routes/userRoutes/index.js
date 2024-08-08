const express = require('express');
const UserController = require('../../controller/UserController');
const authMiddleware = require('../../middlewares/authMiddleware');

const router = express.Router();

router.get('/:id', authMiddleware, UserController.getUser);
router.put('/:id', authMiddleware, UserController.updateUser);

module.exports = router;
