const Group = require('../../models/Group');
const QRCode = require('qrcode');

module.exports = {
  // Cria um novo grupo
  async createGroup(req, res) {
    const { name, members } = req.body;

    try {
      const group = await Group.create({ name, members: [] }); // Inicialmente, cria o grupo sem membros

      res.status(201).json(group);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao criar grupo' });
    }
  },

  // Obtém os detalhes de um grupo
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

  // Gera um QR code para o convite de um grupo
  async generateInviteQRCode(req, res) {
    const { id } = req.params; // ID do grupo

    try {
      const group = await Group.findById(id);
      if (!group) {
        return res.status(404).json({ error: 'Grupo não encontrado' });
      }

      // Gera uma URL para o convite
      const inviteUrl = `${process.env.APP_URL}/invite/${group._id}`;

      // Gera o QR code a partir da URL do convite
      const qrCodeDataUrl = await QRCode.toDataURL(inviteUrl);

      res.json({ qrCodeDataUrl });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao gerar QR code do convite' });
    }
  },

  // Aceita um convite e adiciona o usuário ao grupo via QR code
  async acceptInvite(req, res) {
    const { inviteToken } = req.params; // Token do convite (ID do grupo)
    const { userId } = req.body; // ID do usuário que está aceitando o convite

    try {
      const group = await Group.findById(inviteToken); // Aqui, inviteToken é o ID do grupo
      if (!group) {
        return res.status(404).json({ error: 'Convite inválido ou expirado' });
      }

      // Adiciona o usuário ao grupo
      group.members.push(userId);
      await group.save();

      res.json({ message: 'Convite aceito com sucesso', group });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Erro ao aceitar convite' });
    }
  },
};
