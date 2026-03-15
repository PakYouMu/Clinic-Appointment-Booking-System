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

export const GET_AVAILABLE_SLOTS_QUERY = gql`
  query GetAvailableSlots($doctorId: ID!, $date: ISO8601Date!) {
    availableSlots(doctorId: $doctorId, date: $date)
  }
`

export const GET_MY_APPOINTMENTS_QUERY = gql`
  query GetMyAppointments {
    myAppointments {
      id
      startDatetime
      status
      reasonForVisit
      doctor {
        firstName
        lastName
        specialty
      }
    }
  }
`
