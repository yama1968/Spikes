
const express = require("express");
const app = express();
const crypto = require("crypto");
const multer = require("multer");
const path = require("path");


const storage = multer.diskStorage({
    destination: "/tmp/uploads/",
    filename: function(req, file, callback) {
        //
        crypto.pseudoRandomBytes(16, function(err, raw) {
            if (err) return callback(err);

            callback(null, raw.toString('hex') + '-' + path.basename(file.originalname));
        });
    }
});

const upload = multer({ storage: storage });


app.get('/', (req, res) => {
    res.send('hello, world\n');
});

app.post('/image', (req, res) => {
    upload.single("img")(req, res, (err) => {
        if(err) {
            console.log(`Error ${err}`);
            res.status(400).send(`Something went wrong! ${err}\n`);
        } else {
            console.log(`Got one, going to ${req.file.path}`);
            res.send(req.file);  
        }
    })
})

app.post('/array', upload.array("img", 4), (req, res) => {
    try {
        res.send(req.files);
    } catch (error) {
        console.log(error);
        res.send(400);
    }
})


app.listen(3000, () => {
    console.log("started on port 3000");
})

// test with curl -X POST -F 'img=@foo.jpg' http://localhost:3000/image'