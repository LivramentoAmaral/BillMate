const User = require('../../models/User');
const jwt = require('jsonwebtoken');

module.exports = {
  async register(req, res) {
    const { name, email, password } = req.body;

    try {
      const user = await User.create({ name, email, password });
      const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
      res.status(201).json({ user, token });
    } catch (err) {
      res.status(400).json({ error: 'Erro ao registrar usuário' });
    }
  },

  async login(req, res) {
    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (!user || !await user.comparePassword(password)) {
      return res.status(400).json({ error: 'Credenciais inválidas' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ user, token });
  },
};
