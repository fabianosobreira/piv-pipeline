module.exports = function auth(req, res, next) {
  if (!req.get('authorization')) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  next();
};
