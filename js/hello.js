
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
    name: 'John',
    [id]: 123,
    sayHi: function() {
        console.log(`Hello ${this.name}!`);
    }
}
