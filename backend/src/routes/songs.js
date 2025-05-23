const express = require('express');
const router = express.Router();
const Song = require('../models/song');

// GET all songs
router.get('/', async (req, res) => {
  try {
    const songs = await Song.find().sort({ createdAt: -1 });
    res.json(songs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET single song
router.get('/:id', async (req, res) => {
  try {
    const song = await Song.findById(req.params.id);
    if (song) {
      res.json(song);
    } else {
      res.status(404).json({ message: 'Song not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST new song
router.post('/', async (req, res) => {
  const song = new Song({
    title: req.body.title,
    artist: req.body.artist,
    url: req.body.url,
    imageUrl: req.body.imageUrl,
    duration: req.body.duration,
  });

  try {
    const newSong = await song.save();
    res.status(201).json(newSong);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// PUT update song
router.put('/:id', async (req, res) => {
  try {
    const song = await Song.findById(req.params.id);
    if (song) {
      song.title = req.body.title || song.title;
      song.artist = req.body.artist || song.artist;
      song.url = req.body.url || song.url;
      song.imageUrl = req.body.imageUrl || song.imageUrl;
      song.duration = req.body.duration || song.duration;

      const updatedSong = await song.save();
      res.json(updatedSong);
    } else {
      res.status(404).json({ message: 'Song not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// DELETE song
router.delete('/:id', async (req, res) => {
  try {
    const song = await Song.findById(req.params.id);
    if (song) {
      await song.deleteOne();
      res.json({ message: 'Song deleted' });
    } else {
      res.status(404).json({ message: 'Song not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// SEARCH songs
router.get('/search/:query', async (req, res) => {
  try {
    const query = req.params.query;
    const songs = await Song.find({
      $or: [
        { title: { $regex: query, $options: 'i' } },
        { artist: { $regex: query, $options: 'i' } },
      ],
    });
    res.json(songs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;