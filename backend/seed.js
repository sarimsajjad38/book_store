const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');
const User = require('./models/User');
const Book = require('./models/Book');
const Order = require('./models/Order');

dotenv.config({ path: path.resolve(__dirname, '.env') });
dotenv.config();

const sampleBooks = [
  {
    title: 'A Brief History of Time',
    author: 'Stephen Hawking',
    description: 'A landmark volume in science writing by one of the great minds of our time. Hawking attempts to explain a range of subjects in cosmology, including the Big Bang, black holes, and light cones.',
    price: 299,
    imageUrl: 'https://m.media-amazon.com/images/I/81DBK93b6jL.jpg',
    category: 'Science',
    quantity: 50,
    rating: 4.7,
    reviewCount: 1245,
    isFeatured: true,
  },
  {
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    description: 'In Sapiens, Dr Yuval Noah Harari spans the whole of human history, from the very first humans to walk the earth to the radical breakthroughs of the Cognitive, Agricultural and Scientific Revolutions.',
    price: 399,
    imageUrl: 'https://m.media-amazon.com/images/I/713jIoMO3UL.jpg',
    category: 'History',
    quantity: 35,
    rating: 4.8,
    reviewCount: 2103,
    isFeatured: true,
  },
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    description: 'Tiny Changes, Remarkable Results. No matter your goals, Atomic Habits offers a proven framework for improving—every day.',
    price: 349,
    imageUrl: 'https://m.media-amazon.com/images/I/81YkqyaFVEL.jpg',
    category: 'Self-Help',
    quantity: 80,
    rating: 4.9,
    reviewCount: 5421,
    isFeatured: true,
  },
  {
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    description: 'The story of the mysteriously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.',
    price: 199,
    imageUrl: 'https://m.media-amazon.com/images/I/71FTb9X6wsL.jpg',
    category: 'Fiction',
    quantity: 60,
    rating: 4.5,
    reviewCount: 3200,
    isFeatured: false,
  },
  {
    title: 'Clean Code',
    author: 'Robert C. Martin',
    description: 'A Handbook of Agile Software Craftsmanship. Clean Code is divided into three parts which guide you through the principles, patterns, and practices of writing clean code.',
    price: 499,
    imageUrl: 'https://m.media-amazon.com/images/I/41xShlnTZTL.jpg',
    category: 'Technology',
    quantity: 25,
    rating: 4.6,
    reviewCount: 1890,
    isFeatured: true,
  },
  {
    title: 'Gitanjali',
    author: 'Rabindranath Tagore',
    description: 'A collection of poems by the Bengali poet, originally published in 1910. The English translation was published in 1912.',
    price: 149,
    imageUrl: 'https://m.media-amazon.com/images/I/71c1S1UsMML.jpg',
    category: 'Poetry',
    quantity: 40,
    rating: 4.8,
    reviewCount: 890,
    isFeatured: false,
  },
  {
    title: 'Steve Jobs',
    author: 'Walter Isaacson',
    description: 'Based on more than forty interviews with Jobs conducted over two years. The exclusive biography of Apple co-founder.',
    price: 450,
    imageUrl: 'https://m.media-amazon.com/images/I/81VStYnDGrL.jpg',
    category: 'Biography',
    quantity: 30,
    rating: 4.7,
    reviewCount: 2450,
    isFeatured: true,
  },
  {
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    description: "Timeless lessons on wealth, greed, and happiness. Doing well with money isn't about how smart you are. It's about how you behave.",
    price: 299,
    imageUrl: 'https://m.media-amazon.com/images/I/71TRUbzcvaL.jpg',
    category: 'Self-Help',
    quantity: 70,
    rating: 4.8,
    reviewCount: 3100,
    isFeatured: true,
  },
  {
    title: 'Sherlock Holmes: Complete Collection',
    author: 'Arthur Conan Doyle',
    description: 'The complete collection of Sherlock Holmes stories, featuring the greatest detective of all time.',
    price: 599,
    imageUrl: 'https://m.media-amazon.com/images/I/81MFpGCCejL.jpg',
    category: 'Mystery',
    quantity: 20,
    rating: 4.9,
    reviewCount: 4500,
    isFeatured: false,
  },
  {
    title: 'Pride and Prejudice',
    author: 'Jane Austen',
    description: 'Since its immediate success in 1813, Pride and Prejudice has remained one of the most popular novels in the English language.',
    price: 179,
    imageUrl: 'https://m.media-amazon.com/images/I/71Q1tPupKjL.jpg',
    category: 'Romance',
    quantity: 45,
    rating: 4.7,
    reviewCount: 3800,
    isFeatured: false,
  },
  {
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    description: 'The magical story of Santiago, an Andalusian shepherd boy who yearns to travel in search of a treasure.',
    price: 249,
    imageUrl: 'https://m.media-amazon.com/images/I/71aFt4+OTOL.jpg',
    category: 'Fiction',
    quantity: 55,
    rating: 4.6,
    reviewCount: 6200,
    isFeatured: true,
  },
  {
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    description: 'A groundbreaking tour of the mind, explaining the two systems that drive the way we think.',
    price: 379,
    imageUrl: 'https://m.media-amazon.com/images/I/71wvKXWfcML.jpg',
    category: 'Non-Fiction',
    quantity: 35,
    rating: 4.5,
    reviewCount: 2800,
    isFeatured: false,
  },
];

async function seed() {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/booknest';
    console.log(`Connecting to MongoDB at: ${mongoUri}`);
    await mongoose.connect(mongoUri);

    console.log('Clearing existing data...');
    await Promise.all([User.deleteMany(), Book.deleteMany(), Order.deleteMany()]);

    console.log('Creating initial users...');
    const admin = await User.create({
      name: 'Admin User',
      email: 'admin@booknest.com',
      password: 'password123',
      role: 'admin',
      phone: '9876543210',
      address: '123 Admin Street, New Delhi',
    });

    const seller1 = await User.create({
      name: 'Kumar Harsh',
      email: 'seller@booknest.com',
      password: 'password123',
      role: 'seller',
      phone: '9876543211',
      address: '456 Book Lane, Mumbai',
    });

    const seller2 = await User.create({
      name: 'Rohit Kumar Bhagat',
      email: 'priya@booknest.com',
      password: 'password123',
      role: 'seller',
      phone: '9876543212',
      address: '789 Library Road, Bangalore',
    });

    const customer = await User.create({
      name: 'Roshan sher Singh',
      email: 'customer@booknest.com',
      password: 'password123',
      role: 'customer',
      phone: '9876543213',
      address: '101 Reader Avenue, Kolkata 700001',
    });

    console.log('Inserting books...');
    const booksToInsert = sampleBooks.map((b, i) => ({
      ...b,
      sellerId: i % 2 === 0 ? seller1._id : seller2._id,
    }));
    const createdBooks = await Book.insertMany(booksToInsert);

    console.log('Creating sample orders...');
    await Order.create({
      userId: customer._id,
      userName: customer.name,
      items: [
        {
          bookId: createdBooks[0]._id,
          title: createdBooks[0].title,
          author: createdBooks[0].author,
          imageUrl: createdBooks[0].imageUrl,
          price: createdBooks[0].price,
          quantity: 1,
        },
        {
          bookId: createdBooks[2]._id,
          title: createdBooks[2].title,
          author: createdBooks[2].author,
          imageUrl: createdBooks[2].imageUrl,
          price: createdBooks[2].price,
          quantity: 2,
        },
      ],
      totalAmount: createdBooks[0].price + (createdBooks[2].price * 2),
      status: 'shipped',
      shippingAddress: customer.address,
      paymentMethod: 'COD',
      trackingId: `TRK${Date.now()}`,
    });

    console.log('✅ Database seeded successfully!');
    console.log('--------------------------------------------------');
    console.log('Sample Accounts (Password for all: password123):');
    console.log('  Admin:    admin@booknest.com');
    console.log('  Seller:   seller@booknest.com');
    console.log('  Customer: customer@booknest.com');
    console.log(`Total Books: ${createdBooks.length}`);
    console.log('--------------------------------------------------');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seed();

