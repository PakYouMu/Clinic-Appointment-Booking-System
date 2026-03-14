import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client/core'
import { setContext } from '@apollo/client/link/context'

const httpLink = createHttpLink({
    uri: import.meta.env.VITE_API_URL || 'http://localhost:3000/graphql',
    credentials: 'include'
})

const authLink = setContext((_, { headers }) => {
    return {
        headers: {
            ...headers,
            'x-app-type': 'patient',
        }
    }
})

export const apolloClient = new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache(),
    defaultOptions: {
        watchQuery: {
            fetchPolicy: 'network-only'
        },
        query: {
            fetchPolicy: 'network-only'
        }
    }
})