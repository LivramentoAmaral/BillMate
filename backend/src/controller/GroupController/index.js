const Group = require('../../models/Group');
const QRCode = require('qrcode');
const User = require('../../models/User');

module.exports = {
  async createGroup(req, res) {
    const { name, owner, members } = req.body;

    try {
      const accountType = await User.findById(owner).select('accountType');

      const groups = await Group.find({ $or: [{ owner: owner }, { members: owner }] });

      if (accountType.accountType !== 'premium' && groups.length < 2) {
        const group = await Group.create({ name, owner, members: [] });
        res.status(201).json(group);
      } else {
        return res.status(400).json({ error: 'Atualize o plano da sua conta para criar mais grupos' });
      }
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao criar grupo' });
    }
  },

  async listMyGroups(req, res) {
    const { id } = req.params;

    try {
      const groups = await Group.find({
        $or: [{ owner: id }, { members: id }],
      }).populate('members');
      res.json(groups);
    }
    catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao obter grupos' });
    }
  },

  async deleteGroup(req, res) {
    const { userId, groupId } = req.params;

    try {
      const group = await Group.findById(groupId);

      if (!group) {
        return res.status(404).json({ error: 'Grupo não encontrado' });
      }

      if (group.owner !== userId) {
        return res.status(401).json({ error: 'Você não tem permissão para deletar este grupo' });
      }

      await group.deleteOne();
      res.json({ message: 'Grupo deletado com sucesso' });
    }
    catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao deletar grupo' });
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
    const { inviteToken, userId } = req.body;

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
