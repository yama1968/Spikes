//routes.js

import Home from './components/Home.vue'
import Register from './components/Register.vue'
import Login from './components/Login.vue'
import Student from './components/Student.vue'

const routes = [
    { path: '/', component: Home },
    { path: '/register', component: Register },
    { path: '/login', component: Login },
    { path: '/student/:id', component: Student },
]

export default routes