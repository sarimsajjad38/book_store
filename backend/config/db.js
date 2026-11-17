const mongoose = require('mongoose');

const connectDB = async () => {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/booknest';
  try {
    const conn = await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000,
    });
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`⚠️  MongoDB Connection Warning: ${error.message}`);
    console.log(`   Attempted URI: ${mongoUri}`);
    console.log('   ℹ️  The API server is running, but database operations require MongoDB.');
    console.log('   👉 Start MongoDB locally (e.g. "mongod" or "docker-compose up -d")');
    console.log('   👉 Or set a remote MONGODB_URI (e.g. MongoDB Atlas) in backend/.env');
  }
};

module.exports = connectDB;
