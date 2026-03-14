class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  enum :status, { booked: 0, completed: 1, cancelled: 2, no_show: 3 }

  validates :start_datetime, :end_datetime, presence: true
  
  # Custom Validation Methods
  validate :must_be_at_least_one_hour_in_advance, on: :create
  validate :doctor_must_not_be_double_booked

  private

  def must_be_at_least_one_hour_in_advance
    return if start_datetime.blank?

    # Compare the requested start time to current time + 1 hour
    if start_datetime <= 1.hour.from_now
      errors.add(:start_datetime, "must be booked at least 1 hour in advance")
    end
  end

  def doctor_must_not_be_double_booked
    return if start_datetime.blank? || end_datetime.blank? || doctor_id.blank?

    # Find any existing appointments for this doctor that overlap with this timeframe
    # Status 2 is 'cancelled', so we ignore those.
    overlapping_appointments = Appointment.where(doctor_id: doctor_id)
                                          .where.not(status: :cancelled)
                                          .where.not(id: id) # Ignore self if updating
                                          .where(
                                            "(start_datetime < ? AND end_datetime > ?)", 
                                            end_datetime, 
                                            start_datetime
                                          )

    if overlapping_appointments.exists?
      errors.add(:base, "The doctor is already booked for this time slot")
    end
  end
end