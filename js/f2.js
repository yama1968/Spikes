
const fetch = require('node-fetch');

fetch("http://no.such.server.blabla")
    .then(response => console.log(response.json()))
    .catch(err => {
        console.log("Handling '" + err.message + "'");
        throw err;
    })