const mongoose = require('mongoose');

const songSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  artist: {
    type: String,
    required: true
  },
  album: {
    type: String,
    default: 'Unknown'
  },
  duration: {
    type: Number,
    required: true
  },
  url: {
    type: String,
    required: true
  },
  coverImage: {
    type: String,
    default: 'default-cover.jpg'
  },
  genre: {
    type: String,
    default: 'Unknown'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Song = mongoose.model('Song', songSchema);

module.exports = Song; 