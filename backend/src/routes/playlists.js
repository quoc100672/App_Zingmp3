const express = require('express');
const router = express.Router();

// GET all playlists
router.get('/', async (req, res) => {
  try {
    res.json({ message: 'Get all playlists' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET single playlist
router.get('/:id', async (req, res) => {
  try {
    res.json({ message: `Get playlist ${req.params.id}` });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST new playlist
router.post('/', async (req, res) => {
  try {
    res.status(201).json({ message: 'Create new playlist' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// PUT update playlist
router.put('/:id', async (req, res) => {
  try {
    res.json({ message: `Update playlist ${req.params.id}` });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// DELETE playlist
router.delete('/:id', async (req, res) => {
  try {
    res.json({ message: `Delete playlist ${req.params.id}` });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;