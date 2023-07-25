const express = require('express');
const User = require('../models/users.model');
const config = require('../config');
const middleware = require('../middleware');
const jwt = require('jsonwebtoken');
const bcrypt = require("bcrypt");
const nodemailer = require('nodemailer');

const router = express.Router();



router.route('/:username').get(middleware.checkToken, (req, res) => {
    User.findOne(
        { username: req.params.username },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            const msg = {
                data: result,
                username: req.params.username,
            };
            return res.json(msg);
        }
    );
});

router.route('/checkusername/:username').get((req, res) => {
    User.findOne(
        { username: req.params.username },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            if (result === null) {
                return res.json({ status: false });
            } else {
                return res.json({ status: true });
            }
        }
    );
});

router.route('/checkemail/:email').get((req, res) => {
    User.findOne(
        { email: req.params.email },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            if (result === null) {
                return res.json({ status: false });
            } else {
                return res.json({ status: true });
            }
        }
    );
});


router.route('/login').post((req, res) => {
    User.findOne(
        { username: req.body.username },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            if (result === null) {
                return res.status(403).json({ msg: 'Incorrect Username' });
            }

            bcrypt.compare(req.body.password, result.password, function(err, nresult) {
                if (nresult) {
                    // password is valid
                    let token = jwt.sign(
                        { username: req.body.username },
                        config.key,
                        {},
                    );
                    res.json({
                        token: token,
                        msg: 'success',
                    });
                } else {
                    res.status(403).json({ msg: 'Incorrect Password' });
                }
            });
        }
    );
});

router.route('/register').post((req, res) => {
    passw = req.body.password;
    passwd = '';
    bcrypt.hash(passw, 10, function(err, hash) {
        // store hash in the database
        passwd = hash;
	if (err) return '';
	else {

    const user = new User({
        username: req.body.username,
        password: passwd,
        email: req.body.email,
	hardOfHearing: req.body.hardofhearing,
        resetCode: null,
        resetCodeExpires: null,
    });
    user.save().then(() => {
        let token = jwt.sign(
            { username: req.body.username },
            config.key,
            {},
        );
        res.json({
            token: token,
            msg: 'success',
        });
    }).catch((err) => {
        res.status(403).json({ msg: err });
   });

	}
    });
});


router.route('/update/:username').patch(middleware.checkToken, (req, res) => {
    User.findOneAndUpdate(
        { username: req.params.username },
        { $set: { password: req.body.password } },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            const msg = {
                msg: 'Password successfully updated.',
                username: req.params.username,
            };
            return res.json(msg);
        }
    );
});


router.route('/delete/:username').delete(middleware.checkToken, (req, res) => {
    User.findOneAndDelete(
        { username: req.params.username },
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });
            const msg = {
                msg: 'User Deleted.',
                username: req.params.username,
            };
            return res.json(msg);
        }
    );
});


// Password reset request endpoint
router.route('/reset-password').post((req, res) => {

   email = req.body.email;

  try {

    // Generate a reset code
    const resetCode = generateResetCode();

    User.findOneAndUpdate(
        { email: email },
        { $set: { resetCode: resetCode,
		  resetCodeExpires: Date.now() + 60 * 60 * 1000 // Reset code valid for 1 hour
		}
	},
        (err, result) => {
            if (err) return res.status(500).json({ msg: err });

            // Send the reset code to the user's email
             if (email !== '') sendResetCodeEmail(email, resetCode);

            res.status(200).json({ message: 'Password reset email sent successfully.' });

        }
    );

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error.' });
  }
});


// Password reset verification and update endpoint
router.route('/reset-password/verify').post((req, res) => {
  const { email, resetCode, newPassword } = req.body;

  try {
    User.findOne(
      { email: email },
      (err, user) => {
        if (err) return res.status(500).json({ msg: err });

        // Check if the reset code is valid and not expired
        if (!user || resetCode !== user.resetCode || Date.now() > user.resetCodeExpires) {
          return res.status(400).json({ message: 'Invalid or expired reset code.' });
        }

        // Update the user's password
        bcrypt.hash(newPassword, 10, function(err, hash) {
          if (err) return res.status(500).json({ msg: err });

          // Here, you can implement your own logic to update the user's password
          user.password = hash;
          user.resetCode = null;
          user.resetCodeExpires = null;

          user.save((err) => { // Save the updated user document
            if (err) return res.status(500).json({ msg: err });

            res.status(200).json({ message: 'Password reset successful.' });
          });
        });
      }
    );
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error.' });
  }
});



// Function to generate a reset code
function generateResetCode() {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let resetCode = '';
    for (let i = 0; i < 6; i++) {
      const randomIndex = Math.floor(Math.random() * characters.length);
      resetCode += characters[randomIndex];
    }
    return resetCode;
}



// Function to send the reset code email
async function sendResetCodeEmail(email, resetCode) {
  	// Nodemailer setup for Outlook.com
	const transporter = nodemailer.createTransport({
  		host: 'smtp-mail.outlook.com',
  		port: 587,
  		secure: false,
  		auth: {
                // Put your Outlook.com email address here
    			user: 'outlookemail@outlook.com',
                // Put your Outlook.com password here
    			pass: 'password',
  		},
  		tls: {
    			ciphers: 'SSLv3',
  		},
	});



 	const mailOptions = {
            // Put your Outlook.com email address here
    		from: 'outlookemail@outlook.com',
    		to: email,
    		subject: 'Password Reset',
    		text: `Your password reset code is: ${resetCode}`,
  	};

	transporter.sendMail(mailOptions, (error, info) => {
		if(error) {
			console.error(error);
		} else {
			console.log(info.response);
		}
	});
}


module.exports = router;
