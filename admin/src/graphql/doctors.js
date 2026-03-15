import gql from 'graphql-tag'

export const GET_DOCTORS_QUERY = gql`
  query GetDoctors {
    doctors {
      id
      firstName
      lastName
      specialty
      isActive
    }
  }
`

export const CREATE_DOCTOR_MUTATION = gql`
  mutation CreateDoctor($firstName: String!, $lastName: String!, $specialty: String!) {
    createDoctor(input: { firstName: $firstName, lastName: $lastName, specialty: $specialty }) {
      doctor {
        id
        firstName
        lastName
      }
      errors
    }
  }
`

export const UPDATE_DOCTOR_MUTATION = gql`
  mutation UpdateDoctor($id: ID!, $firstName: String, $lastName: String, $specialty: String, $isActive: Boolean) {
    updateDoctor(input: { id: $id, firstName: $firstName, lastName: $lastName, specialty: $specialty, isActive: $isActive }) {
      doctor {
        id
        firstName
        lastName
        specialty
        isActive
      }
      errors
    }
  }
`
