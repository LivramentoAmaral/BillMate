const express = require('express');
const GroupController = require('../../controller/GroupController');
const router = express.Router();

router.post('/groups', GroupController.createGroup);

router.get('/groups/:id', GroupController.getGroup);

router.get('/groups/:id/invite/qrcode', GroupController.generateInviteQRCode);

router.post('/invite/:inviteToken', GroupController.acceptInvite);

module.exports = router;
