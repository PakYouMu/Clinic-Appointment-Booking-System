class User < ApplicationRecord
  has_secure_password # Required for password_digest
  
  has_one :patient, dependent: :destroy
  
  enum :role, { patient: 0, admin: 1 }

  validates :email, presence: true, uniqueness: true
end