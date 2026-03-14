class Schedule < ApplicationRecord
  belongs_to :doctor

  validates :date, :start_time, :end_time, presence: true
end