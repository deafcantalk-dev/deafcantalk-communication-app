const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const Chat = Schema({
    	sessionId: String,
	username: String,
    	text: String,
	isMe: String,
	time: String,
});

module.exports = mongoose.model('Chat', Chat);
