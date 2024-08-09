const express = require('express');
const GroupController = require('../../controller/GroupController');
const router = express.Router();

router.post('/', GroupController.createGroup);

router.get('my/:id', GroupController.listMyGroups);

router.delete('/:userId/:groupId', GroupController.deleteGroup);

router.get('/:id', GroupController.getGroup);

router.get('/:id/invite/qrcode', GroupController.generateInviteQRCode);

router.post('/invite/', GroupController.acceptInvite);

module.exports = router;
