class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor

  # Added 'booked' as default
  enum :status, { booked: 0, completed: 1, cancelled: 2, no_show: 3 }

  validates :start_datetime, :end_datetime, :reason_for_visit, :contact_number, presence: true
  validates :contact_number, length: { minimum: 10, maximum: 20 },
            format: { with: /\A\+?\d[\d\s\-()]{8,18}\d\z/,
                       message: "must be a valid phone number (e.g., +639123456789)" }
  validates :reason_for_visit, length: { maximum: 500 }

  # Sanitize text inputs before validation
  before_validation :sanitize_inputs

  # Custom Validation Methods
  validate :must_be_at_least_one_hour_in_advance, on: :create
  validate :doctor_must_not_be_double_booked
  
  def cancellable?
    booked? && start_datetime > 1.hour.from_now
  end

  private

  def must_be_at_least_one_hour_in_advance
    return if start_datetime.blank?

    if start_datetime <= 1.hour.from_now
      errors.add(:start_datetime, "must be booked at least 1 hour in advance")
    end
  end

  def doctor_must_not_be_double_booked
    return if start_datetime.blank? || end_datetime.blank? || doctor_id.blank?

    overlapping_appointments = Appointment.where(doctor_id: doctor_id)
                                          .where.not(status: :cancelled)
                                          .where.not(id: id)
                                          .where("(start_datetime < ? AND end_datetime > ?)", 
                                                 end_datetime, 
                                                 start_datetime)

    if overlapping_appointments.exists?
      errors.add(:base, "The doctor is already booked for this time slot")
    end
  end

  def sanitize_inputs
    # Strip HTML tags from reason_for_visit
    if reason_for_visit.present?
      self.reason_for_visit = reason_for_visit.gsub(/<[^>]*>/, '').strip
    end

    # Normalize phone: keep only digits, +, spaces, hyphens, parens
    if contact_number.present?
      self.contact_number = contact_number.gsub(/[^\d+\s\-()]/, '').strip
    end
  end
end