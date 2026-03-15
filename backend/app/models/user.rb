class User < ApplicationRecord
  has_secure_password # Required for password_digest
  
  has_one :patient, dependent: :destroy
  
  enum :role, { patient: 0, admin: 1 }

  validates :email, presence: true, uniqueness: true
  validates :phone_number, length: { minimum: 10, maximum: 20 }, allow_nil: true,
            format: { with: /\A\+?\d[\d\s\-()]{8,18}\d\z/,
                       message: "must be a valid phone number" }

  # Sanitize phone before validation
  before_validation :sanitize_phone

  private

  def sanitize_phone
    return if phone_number.blank?
    self.phone_number = phone_number.gsub(/[^\d+\s\-()]/, '').strip
  end
end