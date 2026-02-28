import { DefaultApolloClient } from '@vue/apollo-composable'
import { apolloClient } from './models/apolloClient'

const app = createApp(App)

app.provide(DefaultApolloClient, apolloClient)

app.mount('#app')