const jwt = require('jsonwebtoken');
const User = require('../../models/User');

module.exports = async (req, res, next) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return res.status(401).json({ error: 'Token não fornecido' });
  }

  const token = authorization.replace('Bearer ', '');

  try {
    const { id } = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(id);
    next();
  } catch (err) {
    res.status(401).json({ error: 'Token inválido' });
  }
};
