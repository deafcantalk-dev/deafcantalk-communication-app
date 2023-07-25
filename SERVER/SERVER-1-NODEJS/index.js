const express = require('express');             // Import expressjs
const mongoose = require('mongoose');           // Import mongoose

const port = process.env.PORT || 3000;
const app = express();


// Connect to MongoDB
mongoose.set('strictQuery', false);
mongoose.connect('mongodb+srv://<username>:<password>@<cluster>/<database>?retryWrites=true&w=majority');
const connection = mongoose.connection;
connection.once('open', () => {
  console.log('MongoDB connected');
});


// middleware
app.use('/uploads', express.static('uploads'));   // Make uploads folder to make it accessible from browser
app.use(express.json());    // For Json Data

// User Route
const userRoute = require('./routes/user');
app.use('/user', userRoute);

// Profile Route
const profileRoute = require('./routes/profile');
app.use('/profile', profileRoute);


// chat Route
const chatRoute = require('./routes/chat');
app.use('/chat', chatRoute);


// Root Route
app.get("/", (req, res) => {
  res.send("Deaf Can Talk!");
});


// Added 0.0.0.0 to run server from local ip address
app.listen(port, '0.0.0.0', () => console.log(`Your server is running`));
