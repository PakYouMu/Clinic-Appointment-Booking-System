import './assets/index.css'
import { createApp } from 'vue'
import { DefaultApolloClient } from '@vue/apollo-composable'
import { apolloClient } from './models/apolloClient'
import router from './router'
import App from './views/App.vue'

const app = createApp(App)

app.provide(DefaultApolloClient, apolloClient)
app.use(router)

app.mount('#app')