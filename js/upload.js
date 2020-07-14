
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");


const storage = multer.diskStorage({
    destination: "/tmp",
    filename: function(req, file, callback) {
        //
        crypto.pseudoRandomBytes(16, function(err, raw) {
            if (err) return callback(err);

            callback(null, raw.toString('hex') + path.extname(file.originalname));
        });
    }
});

const upload = multer({ dest: '/tmp' });


const bodyParser = require("body-parser");
const express = require("express");
// const morgan = require('morgan');


const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
// app.use(morgan.dev);

app.post('/', upload.single('avatar'), (req, res) => {
    if (!req.file) {
        console.log("No file received");
        return res.send({success: false});
    } else {
        console.log("File received");
        return res.send({success: true});
    }
});


// app.use(express.static(__dirname, 'public'));

app.listen(3000);