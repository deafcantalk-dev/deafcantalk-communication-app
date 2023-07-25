const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const Session = Schema({
	sessionId: String,
	username: String,
	lastMsg: String,
});

module.exports = mongoose.model('Session', Session);
