const mongoose = require('mongoose');
const Song = require('../models/song');
require('dotenv').config();

const sampleSongs = [
  {
    title: "Shape of You",
    artist: "Ed Sheeran",
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    imageUrl: "https://example.com/shape-of-you.jpg",
    duration: 235,
  },
  {
    title: "Blinding Lights",
    artist: "The Weeknd",
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    imageUrl: "https://example.com/blinding-lights.jpg",
    duration: 200,
  },
  {
    title: "Dance Monkey",
    artist: "Tones and I",
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    imageUrl: "https://example.com/dance-monkey.jpg",
    duration: 210,
  },
  {
    title: "Watermelon Sugar",
    artist: "Harry Styles",
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    imageUrl: "https://example.com/watermelon-sugar.jpg",
    duration: 190,
  },
  {
    title: "Levitating",
    artist: "Dua Lipa",
    url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
    imageUrl: "https://example.com/levitating.jpg",
    duration: 203,
  },
];

async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/music_app');
    console.log('Connected to MongoDB');

    // Delete existing songs
    await Song.deleteMany({});
    console.log('Deleted existing songs');

    // Insert sample songs
    const songs = await Song.insertMany(sampleSongs);
    console.log('Added sample songs:', songs);

    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase(); 