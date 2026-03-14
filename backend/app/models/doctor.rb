class Doctor < ApplicationRecord
  has_many :schedules, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :first_name, :last_name, :specialty, presence: true
end