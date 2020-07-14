const fetch = require('node-fetch');

async function showUser() {

    let response = await fetch('https://api.github.com/users/iliakan')
    let user = await response.json();

    console.log("inside => " + user.login)

    return user;
}

showUser()
    .then(r => console.log(r.login));
