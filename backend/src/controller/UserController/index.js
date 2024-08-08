const User = require('../../models/User');

module.exports = {
  async getUser(req, res) {
    const { id } = req.params;
    const user = await User.findById(id);

    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    res.json(user);
  },

  async updateUser(req, res) {
    const { id } = req.params;
    const { name, email, rendaFixa } = req.body;

    const user = await User.findByIdAndUpdate(id, { name, email, rendaFixa }, { new: true });

    res.json(user);
  },
};
