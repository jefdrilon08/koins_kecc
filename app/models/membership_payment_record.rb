class MembershipPaymentRecord < ApplicationRecord
  STATUSES  = ["pending", "paid"]

  belongs_to :member

  validates :membership_type, presence: true
  validates :membership_name, presence: true
  validates :amount, presence: true, numericality: true
  validates :date_paid, presence: true

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end
end
