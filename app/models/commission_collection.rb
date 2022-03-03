class CommissionCollection < ApplicationRecord
  STATUSES  = [
    "processing", 
    "pending", 
    "approved",
    "error"
    ]

  validates :date_prepared, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :processing, -> { where(status: "processing") }
  scope :error, -> { where(status: "error") }

  def processing?
    self.status == "processing"
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end

  def error?
    self.status == "error"
  end
end
