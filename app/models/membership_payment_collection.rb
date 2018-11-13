class MembershipPaymentCollection < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved"
  ]

  belongs_to :center
  belongs_to :branch

  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end
end
