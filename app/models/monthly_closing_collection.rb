class MonthlyClosingCollection < ApplicationRecord
  STATUSES  = [
    "processing", 
    "pending", 
    "approved",
    "error"
  ]

  belongs_to :branch

  validates :closing_date, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }

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

  def to_s
    closing_date
  end
end
