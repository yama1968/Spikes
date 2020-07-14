const fetch = require('node-fetch');

let urls = [
    'https://api.github.com/users/iliakan',
    'https://api.github.com/users/remy',
    'https://api.github.com/users/jeresig'
  ];

// map every url to the promise of the fetch
let requests = urls.map(url => fetch(url));

// Promise.all waits until all jobs are resolved
Promise.all(requests)
    .then(responses => responses.forEach(
        response => console.log(`${response.url}: ${response.status}`)
    ))
    .then(reponse => console.log("All finished!"));

console.log("All right");

Promise.all(requests)
.then(responses => {
    for(let response of responses) {
        console.log(`${response.url}: ${response.status}`);
    }
    return responses;
})
.then(responses => Promise.all(responses.map(r => r.json())))
.then(users => users.forEach(user => console.log(user.name)))
.then((x) => console.log("All finished"));


