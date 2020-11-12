//routes.js

import Home from './components/Home.vue'
import Register from './components/Register.vue'
import Login from './components/Login.vue'
import Student from './components/Student.vue'

function getRoutes(recordForRegister1, recordForRegister2) {
    const routes = [
        { path: '/', component: Home },
        { path: '/register1', component: Register, props: { message: 'Register premier, hello!', record: recordForRegister1 } },
        { path: '/register2', component: Register, props: { message: 'Hullo', record: recordForRegister2 } },
        { path: '/login', component: Login, props: { value: recordForRegister1 } },
        { path: '/student/:id', component: Student },
    ]    
    return routes;
}

export default getRoutes

