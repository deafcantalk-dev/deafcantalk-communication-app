const express = require('express');
const Chat = require('../models/chat.model');
const Session = require('../models/session.model');
const middleware = require('../middleware');
const multer = require('multer');
const { json } = require('express/lib/response');

const router = express.Router();

// Multer Configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './uploads');
    },
    filename: (req, file, cb) => {                      // filename of file to be stored
        cb(null, req.params.id + '.jpg');
    },
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 1024 * 1024 * 6,
    },
});

router.route('/add/coverImage/:id').patch(middleware.checkToken, upload.single('img'), (req, res) => {
    Chat.findOneAndUpdate(
        { _id: req.params.id },
        {
            $set: {
                coverImage: req.file.path,
            },
        },
        { new: true },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            return res.json(result);
        }
    );
});

router.route('/add').post(middleware.checkToken, (req, res) => {
    const chat = Chat({
	sessionId: req.body.sessionId,
        username: req.decoded.username,
        text: req.body.text,
        isMe: req.body.isMe,
	time: req.body.time,
    });
    chat
        .save()
        .then((result) => {
            res.json({ data: result['_id'] });
        })
        .catch((err) => {
            res.status(500).json({ msg: err });
        });
});

router.route('/addSession').post(middleware.checkToken, (req, res) => {

	const sessionId = req.body.sessionId;
	Session.findOne({sessionId: sessionId}, (err, existingSession) => {
		if(err) {
			return res.status(500).json({msg: err});
		}

		if(existingSession) {
			return
		}
		const session = Session({
			'sessionId': req.body.sessionId,
			'username': req.decoded.username,
			'lastMsg': req.body.lastMsg,
		});
		session
			.save()
			.then((result) => {
				res.json({ data: result['_id'] });
			})
			.catch((err) => {
		   		res.status(500).json({ msg: err });
			});
	});
});


router.route('/getOwnChats').get(middleware.checkToken, (req, res) => {
    Chat.find({ username: req.decoded.username }, (err, result) => {
        if (err) return res.status(500).json({ msg: err });
        if (result == null) return res.json({ data: [] });
        return res.json({ data: result });
    });
});



router.route('/getOwnMessages').post(middleware.checkToken, (req, res) => {
    Chat.find({ sessionId: req.body.sessionId }, (err, result) => {
        if (err) {
		return res.status(500).json({ msg: err });
	}

        return res.json({ data: result || [] });
    });
});


router.route('/getOwnSessions').get(middleware.checkToken, (req, res) => {
    Session.find({ username: req.decoded.username }, (err, result) => {
        if (err) return res.status(500).json({ msg: err });
        if (result == null) return res.json({ data: [] });
        return res.json({ data: result });
    });
});


router.route('/delete/:id').delete(middleware.checkToken, (req, res) => {
    Chat.findOneAndDelete(
        {
            $and: [{ username: req.decoded.username }, { _id: req.params.id }],
        },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            else if (result) {
                return res.json({ msg: 'Chat deleted' });
            }
            return res.json({ msg: 'Chat not deleted' });
        }
    );
});

module.exports = router;
