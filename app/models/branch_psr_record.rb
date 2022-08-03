class BranchPsrRecord < ApplicationRecord
  STATUSES = [
    "pending",
    "done"
  ]

  belongs_to :branch

  validates :closing_date, presence: true
  validates :closing_year, presence: true
  validates :closing_month, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :done, -> { where(status: "done") }

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def done?
    self.status == "done"
  end

  def pending?
    self.status == "pending"
  end
end
