const jwt = require('jsonwebtoken');

const SECRET     = process.env.JWT_SECRET     || 'XioW5FPP7WBz/gmjSrUb/Xf19BIT7CQ57r4h3ueju4c=';
const EXPIRATION = process.env.JWT_EXPIRATION || '86400000';

function generateToken(username, userId, role) {
  return jwt.sign(
    { sub: username, userId, role },
    SECRET,
    { expiresIn: parseInt(EXPIRATION, 10) / 1000 } // ms → seconds
  );
}

function verifyToken(token) {
  const decoded = jwt.verify(token, SECRET);
  return {
    username: decoded.sub,
    userId:   decoded.userId,
    role:     decoded.role,
  };
}

module.exports = { generateToken, verifyToken };
