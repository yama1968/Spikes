
const express = require("express");
const app = express();

const multer = require("multer");
const upload = multer({dest: '/tmp/uploads/'});


app.get('/', (req, res) => {
    res.send('hello, world\n');
});

app.post('/image', (req, res) => {
    upload.single("img")(req, res, (err) => {
        if(err) {
            res.status(400).send(`Something went wrong! ${err}\n`);
        } else {
            console.log("Got one!");
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