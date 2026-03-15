class Doctor < ApplicationRecord
  has_many :schedules, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :first_name, :last_name, :specialty, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end