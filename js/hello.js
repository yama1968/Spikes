
console.log("Hello, World!");
console.log("Hello, World!");



a & b

function foo (a, b) {
    console.log(`a is ${a}, b is ${b}`)
}

const a = 2;
foo(a = 1, b = 2);
foo(b = 2, a = 1);


function bar ({a, b}) {
    console.log(`a is ${a}, b is ${b}`)
}

bar({'a': 1, 'b': 2})
bar({ 'b': 2, 'a': 1})

function buz (a = 2) {
    return (b) => console.log(`a is ${a}, b is ${b}`)
}

const f = buz(1);
f(2)

const g = buz();
g(3)


function User(name, isAdmin = false) {
    this.name = name;
    this.isAdmin = isAdmin;
}

let user = new User("Jack");

const id = Symbol("id");

let jack = {
    name: 'Jack',
    [id]: 123,
    sayHi: function() {
        console.log(`Hello ${this.name}!`);
    }
}

// Promises

promise2 = new Promise(function(resolve, reject) {
    setTimeout(() => resolve("done"), 10000);
})

function doWait(seconds) {
    return new Promise(function(resolve, reject) {
        setTimeout(() => resolve("done in " + seconds + " sec"), seconds * 1000);
    })
}


function chained() {
    return new Promise(function(resolve, reject) {

        setTimeout(() => resolve(1), 1000); // (*)
      
      }).then(function(result) { // (**)
      
        alert(result); // 1
        return result * 2;
      
      }).then(function(result) { // (***)
      
        alert(result); // 2
        return result * 2;
      
      }).then(function(result) {
      
        alert(result); // 4
        return result * 2;
      
      });
}