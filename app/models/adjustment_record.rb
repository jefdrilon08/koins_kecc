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
  scope :subsidiary, -> { where(adjustment_type: "subsidiary") }

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end
end
