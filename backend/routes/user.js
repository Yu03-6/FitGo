const express = require('express');
const userController = require('../controllers/userController');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

router.use(verifyToken);

router.post('/profile', userController.updateProfile);
router.get('/profile', userController.getProfile);

module.exports = router;
