class Booking < ApplicationRecord
  belongs_to :court
  belongs_to :customer, optional: true

  validates :phonenumber, presence: true, format: { with: /\A\d{10}\z/, message: "must be exactly 10 digits" }
end
