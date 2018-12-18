class MonthlyClosingCollection < ApplicationRecord
  STATUSES  = ["pending", "approved"]

  belongs_to :branch

  validates :closing_date, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }

  def to_s
    closing_date
  end
end
