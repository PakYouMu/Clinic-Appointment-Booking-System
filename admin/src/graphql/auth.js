import gql from 'graphql-tag'

export const SIGN_UP_MUTATION = gql`
  mutation SignUp($input: SignUpInput!) {
    signUp(input: $input) {
      user {
        id
        email
      }
      errors
    }
  }
`

export const SIGN_IN_MUTATION = gql`
  mutation SignIn($input: SignInInput!) {
    signIn(input: $input) {
      user {
        id
        email
      }
      errors
    }
  }
`

export const SIGN_OUT_MUTATION = gql`
  mutation SignOut($input: SignOutInput!) {
    signOut(input: $input) {
      success
    }
  }
`

export const CURRENT_USER_QUERY = gql`
  query CurrentUser {
    currentUser {
      id
      email
    }
  }
`
