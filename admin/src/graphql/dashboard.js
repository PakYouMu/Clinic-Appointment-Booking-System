import gql from 'graphql-tag'

export const GET_DASHBOARD_DATA = gql`
  query GetDashboardData {
    adminAppointments {
      id
      startDatetime
      status
      patient {
        id
        firstName
        lastName
      }
      doctor {
        id
        lastName
      }
    }
    recentActivities {
      id
      type
      title
      description
      timestamp
      iconType
      color
    }
  }
`
