# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_up, mutation: Mutations::SignUp
    field :admin_sign_up, mutation: Mutations::AdminSignUp
    field :sign_in, mutation: Mutations::SignIn
    field :sign_out, mutation: Mutations::SignOut
    field :create_doctor, mutation: Mutations::CreateDoctor
    field :create_schedule, mutation: Mutations::CreateSchedule
    field :book_appointment, mutation: Mutations::BookAppointment
    field :update_appointment_status, mutation: Mutations::UpdateAppointmentStatus
  end
end
