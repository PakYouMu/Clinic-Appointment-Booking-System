import { ref, computed } from 'vue'
import { useMutation, useQuery } from '@vue/apollo-composable'
import { apolloClient } from '../models/apolloClient'
import {
    SIGN_UP_MUTATION,
    SIGN_IN_MUTATION,
    SIGN_OUT_MUTATION,
    CURRENT_USER_QUERY
} from '../graphql/auth'

const currentUser = ref(null)
const loading = ref(true)
const initialized = ref(false)

export function useAuth() {
    const isAuthenticated = computed(() => !!currentUser.value)

    async function fetchCurrentUser() {
        try {
            loading.value = true
            const { data } = await apolloClient.query({
                query: CURRENT_USER_QUERY,
                fetchPolicy: 'network-only'
            })
            currentUser.value = data?.currentUser || null
        } catch {
            currentUser.value = null
        } finally {
            loading.value = false
            initialized.value = true
        }
    }

    async function signUp({ email, password, passwordConfirmation, firstName, lastName, phoneNumber }) {
        const { data } = await apolloClient.mutate({
            mutation: SIGN_UP_MUTATION,
            variables: {
                input: {
                    email,
                    password,
                    passwordConfirmation,
                    firstName,
                    lastName,
                    phoneNumber
                }
            }
        })

        const result = data?.signUp
        if (result?.errors?.length) {
            throw new Error(result.errors.join(', '))
        }

        currentUser.value = result?.user
        return result?.user
    }
    async function signIn({ email, password }) {
        const { data } = await apolloClient.mutate({
            mutation: SIGN_IN_MUTATION,
            variables: {
                input: { email, password }
            }
        })

        const result = data?.signIn
        if (result?.errors?.length) {
            throw new Error(result.errors.join(', '))
        }

        currentUser.value = result?.user
        return result?.user
    }

    async function signOut() {
        try {
            await apolloClient.mutate({
                mutation: SIGN_OUT_MUTATION,
                variables: { input: {} }
            })
        } finally {
            currentUser.value = null
            await apolloClient.clearStore()
        }
    }

    return {
        currentUser,
        isAuthenticated,
        loading,
        initialized,
        fetchCurrentUser,
        signUp,
        signIn,
        signOut
    }
}

