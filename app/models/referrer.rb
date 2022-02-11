class Referrer < ApplicationRecord
  STATUSES = [
    "active",
    "inactive"
  ]

  CATEGORIES = [
  	"REFERRER",
  	"INSURANCE COORDINATOR"
  ]

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :contact_number, presence: true
  validates :status, presence: true
  validates :date_registered, presence: true
  validates :category, presence: true

  has_many :members

  def full_name
    "#{last_name.upcase}, #{first_name.upcase}"
  end
end
