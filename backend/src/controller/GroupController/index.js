const Group = require('../../models/Group');

module.exports = {
  async createGroup(req, res) {
    const { name, members } = req.body;
    const group = await Group.create({ name, members });

    res.status(201).json(group);
  },

  async getGroup(req, res) {
    const { id } = req.params;
    const group = await Group.findById(id).populate('members');

    if (!group) {
      return res.status(404).json({ error: 'Grupo não encontrado' });
    }

    res.json(group);
  },

  async addUserToGroup(req, res) {
    const { id } = req.params;
    const { userId } = req.body;

    const group = await Group.findById(id);
    if (!group) {
      return res.status(404).json({ error: 'Grupo não encontrado' });
    }

    group.members.push(userId);
    await group.save();

    res.json(group);
  },
};
