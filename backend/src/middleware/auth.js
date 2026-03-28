const { verifyToken } = require('../utils/jwt');

function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Token requerido' });
  }

  try {
    req.user = verifyToken(header.slice(7));
    next();
  } catch {
    return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Token invalido o expirado' });
  }
}

module.exports = authMiddleware;
