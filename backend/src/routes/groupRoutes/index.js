const express = require('express');
const GroupController = require('../../controller/GroupController');
const authMiddleware = require('../../middlewares/authMiddleware');

const router = express.Router();

router.post('/', authMiddleware, GroupController.createGroup);
router.get('/:id', authMiddleware, GroupController.getGroup);
router.put('/:id/add', authMiddleware, GroupController.addUserToGroup);

module.exports = router;
