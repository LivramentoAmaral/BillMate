const Group = require('../../models/Group');
const QRCode = require('qrcode');

module.exports = {
  async createGroup(req, res) {
    const { name, members } = req.body;

    try {
      const group = await Group.create({ name, members: [] }); 
      res.status(201).json(group);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao criar grupo' });
    }
  },

  async getGroup(req, res) {
    const { id } = req.params;

    try {
      const group = await Group.findById(id).populate('members');
      if (!group) {
        return res.status(404).json({ error: 'Grupo não encontrado' });
      }
      res.json(group);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao obter grupo' });
    }
  },

  async generateInviteQRCode(req, res) {
    const { id } = req.params;

    try {
      const group = await Group.findById(id);
      if (!group) {
        return res.status(404).json({ error: 'Grupo não encontrado' });
      }

      const inviteUrl = `${process.env.APP_URL}/invite/${group._id}`;

      const qrCodeDataUrl = await QRCode.toDataURL(inviteUrl);

      res.json({ qrCodeDataUrl });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao gerar QR code do convite' });
    }
  },

  async acceptInvite(req, res) {
    const { inviteToken } = req.params; 
    const { userId } = req.body; 

    try {
      const group = await Group.findById(inviteToken); 
      if (!group) {
        return res.status(404).json({ error: 'Convite inválido ou expirado' });
      }

      group.members.push(userId);
      await group.save();

      res.json({ message: 'Convite aceito com sucesso', group });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao aceitar convite' });
    }
  },
};
