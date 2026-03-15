import gql from 'graphql-tag'

export const GET_DOCTOR_SCHEDULES_QUERY = gql`
  query GetDoctorSchedules($id: ID!) {
    doctor(id: $id) {
      id
      firstName
      lastName
      schedules {
        id
        date
        startTime
        endTime
      }
    }
  }
`

export const BULK_CREATE_SCHEDULES_MUTATION = gql`
  mutation BulkCreateSchedules(
    $doctorId: ID!
    $startDate: ISO8601Date!
    $endDate: ISO8601Date!
    $startTime: String!
    $endTime: String!
    $daysOfWeek: [Int!]!
  ) {
    bulkCreateSchedules(
      input: {
        doctorId: $doctorId
        startDate: $startDate
        endDate: $endDate
        startTime: $startTime
        endTime: $endTime
        daysOfWeek: $daysOfWeek
      }
    ) {
      schedules {
        id
        date
      }
      errors
    }
  }
`

export const DELETE_SCHEDULE_MUTATION = gql`
  mutation DeleteSchedule($scheduleId: ID!) {
    deleteSchedule(input: { scheduleId: $scheduleId }) {
      success
      errors
    }
  }
`
