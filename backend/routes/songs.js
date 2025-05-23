const express = require('express');
const router = express.Router();
const Song = require('../models/song');

// Get all songs
router.get('/', async (req, res) => {
  try {
    const songs = await Song.find().sort({ createdAt: -1 });
    res.json(songs);
  } catch (err) {
    console.error('Error fetching songs:', err);
    res.status(500).json({ message: 'Error fetching songs' });
  }
});

// Add a new song
router.post('/', async (req, res) => {
  try {
    const { title, artist, album, duration, url, coverImage, genre } = req.body;
    
    const song = new Song({
      title,
      artist,
      album,
      duration,
      url,
      coverImage,
      genre
    });

    await song.save();
    res.status(201).json(song);
  } catch (err) {
    console.error('Error adding song:', err);
    res.status(500).json({ message: 'Error adding song' });
  }
});

// Get song by ID
router.get('/:id', async (req, res) => {
  try {
    const song = await Song.findById(req.params.id);
    if (!song) {
      return res.status(404).json({ message: 'Song not found' });
    }
    res.json(song);
  } catch (err) {
    console.error('Error fetching song:', err);
    res.status(500).json({ message: 'Error fetching song' });
  }
});

// Update song
router.put('/:id', async (req, res) => {
  try {
    const song = await Song.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!song) {
      return res.status(404).json({ message: 'Song not found' });
    }
    res.json(song);
  } catch (err) {
    console.error('Error updating song:', err);
    res.status(500).json({ message: 'Error updating song' });
  }
});

// Delete song
router.delete('/:id', async (req, res) => {
  try {
    const song = await Song.findByIdAndDelete(req.params.id);
    if (!song) {
      return res.status(404).json({ message: 'Song not found' });
    }
    res.json({ message: 'Song deleted successfully' });
  } catch (err) {
    console.error('Error deleting song:', err);
    res.status(500).json({ message: 'Error deleting song' });
  }
});

module.exports = router; 