# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?

  normalizes :email, with: ->(email) { email.strip.downcase }

  private

  def password_required?
    new_record? || password.present?
  end
end
