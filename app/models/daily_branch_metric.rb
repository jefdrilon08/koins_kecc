class DailyBranchMetric < ApplicationRecord
  STATUSES = [
    "processing",
    "done",
    "error"
  ]

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }

  belongs_to :branch
  belongs_to :cluster
  belongs_to :area

  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :principal, presence: true, numericality: true
  validates :interest, presence: true, numericality: true
  validates :total, presence: true, numericality: true
  validates :principal_due, presence: true, numericality: true
  validates :interest_due, presence: true, numericality: true
  validates :total_due, presence: true, numericality: true
  validates :principal_paid, presence: true, numericality: true
  validates :interest_paid, presence: true, numericality: true
  validates :principal_paid_due, presence: true, numericality: true
  validates :portfolio, presence: true, numericality: true
  validates :interest_paid_due, presence: true, numericality: true
  validates :total_paid_due, presence: true, numericality: true
  validates :total_paid, presence: true, numericality: true
  validates :principal_balance, presence: true, numericality: true
  validates :interest_balance, presence: true, numericality: true
  validates :total_balance, presence: true, numericality: true
  validates :overall_principal_balance, presence: true, numericality: true
  validates :overall_interest_balance, presence: true, numericality: true
  validates :overall_balance, presence: true, numericality: true
  validates :principal_rr, presence: true, numericality: true
  validates :interest_rr, presence: true, numericality: true
  validates :total_rr, presence: true, numericality: true
  validates :par_amount, presence: true, numericality: true
  validates :par, presence: true, numericality: true
  validates :num_days_par, presence: true, numericality: true
  validates :as_of, presence: true

  def processing?
    self.status == "processing"
  end

  def done?
    self.status == "done"
  end
end
