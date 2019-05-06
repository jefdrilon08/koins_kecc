class AdjustmentRecord < ApplicationRecord
  STATUSES  = [
    "pending", 
    "approved"
  ]

  ADJUSTMENT_TYPES  = [
    "reamortization",
    "subsidiary"
  ]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :adjustment_type, presence: true, inclusion: { in: ADJUSTMENT_TYPES }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }

  scope :reamortization, -> { where(adjustment_type: "reamortization") }

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end
end
