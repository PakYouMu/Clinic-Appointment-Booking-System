import gql from 'graphql-tag'

export const BOOK_APPOINTMENT_MUTATION = gql`
  mutation BookAppointment(
    $doctorId: ID!
    $startDatetime: ISO8601DateTime!
    $endDatetime: ISO8601DateTime!
    $contactNumber: String!
    $reasonForVisit: String
  ) {
    bookAppointment(
      input: {
        doctorId: $doctorId
        startDatetime: $startDatetime
        endDatetime: $endDatetime
        contactNumber: $contactNumber
        reasonForVisit: $reasonForVisit
      }
    ) {
      appointment {
        id
        status
        startDatetime
      }
      errors
    }
  }
`

export const CANCEL_APPOINTMENT_MUTATION = gql`
  mutation CancelAppointment($id: ID!) {
    cancelAppointment(input: { id: $id }) {
      appointment {
        id
        status
      }
      errors
    }
  }
`
