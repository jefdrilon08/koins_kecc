class Member < ApplicationRecord
  STATUSES = [
    "blacklisted",
    "whitelisted",
    "active",
    "pending",
    "resign",
    "archived",
    "resigned",
    "for-resignation",
    "dormant",
    "for-withdrawal",
    "for-transfer",
    "transferred",
    "cleared"
  ]

  belongs_to :center
  belongs_to :branch

  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :first_name, presence: true
  validates :middle_name, presence: true
  validates :last_name, presence: true

  validates :identification_number, presence: true, uniqueness: true
  validates :civil_status, presence: true
  validates :home_number, presence: true
  validates :mobile_number, presence: true

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end
end
