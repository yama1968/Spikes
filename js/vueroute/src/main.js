import Vue from 'vue'
import App from './App.vue'
import VueRouter from 'vue-router'

import getRoutes from './routes'

Vue.config.productionTip = false

Vue.use(VueRouter)


const recordForRegister1 = {
  x: 0
}

const recordForRegister2 = {
  x: 0
}

const router = new VueRouter({ 
  routes: getRoutes(recordForRegister1, recordForRegister2) 
})

// const router = new VueRouter({ mode: 'history', routes })


new Vue({
  render: h => h(App),
  router,
}).$mount('#app')
