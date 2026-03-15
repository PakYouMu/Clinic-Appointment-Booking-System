import gql from 'graphql-tag'

export const GET_ADMIN_APPOINTMENTS_QUERY = gql`
  query GetAdminAppointments($date: ISO8601Date, $doctorId: ID, $fromDate: ISO8601Date, $toDate: ISO8601Date) {
    adminAppointments(date: $date, doctorId: $doctorId, fromDate: $fromDate, toDate: $toDate) {
      id
      startDatetime
      endDatetime
      status
      reasonForVisit
      contactNumber
      patient {
        id
        firstName
        lastName
      }
      doctor {
        id
        firstName
        lastName
        specialty
      }
    }
  }
`

export const UPDATE_APPOINTMENT_STATUS_MUTATION = gql`
  mutation UpdateAppointmentStatus($appointmentId: ID!, $status: String!) {
    updateAppointmentStatus(input: { appointmentId: $appointmentId, status: $status }) {
      appointment {
        id
        status
      }
      errors
    }
  }
`
