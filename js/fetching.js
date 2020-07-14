const fetch = require('node-fetch');

fetch('https://www.npmjs.com/package/node-fetch#common-usage')
    .then(function(response) {
        console.log("First function");
        return response.text();
    })
    .then(function(text) {
        console.log(text.length);
    });

