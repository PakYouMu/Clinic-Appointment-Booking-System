class AppointmentMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.appointment_mailer.booking_confirmation.subject
  #
  def booking_confirmation
    @appointment = params[:appointment]
    @patient = @appointment.patient
    @doctor = @appointment.doctor
    
    mail(
      to: @patient.user.email,
      subject: "Appointment Confirmation: #{@doctor.full_name} - #{@appointment.start_datetime.strftime('%B %d, %Y')}"
    )
  end
end
