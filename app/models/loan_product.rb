class LoanProduct < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :max_loan_amount, presence: true, numericality: true
  validates :min_loan_amount, presence: true, numericality: true
  validates :monthly_interest_rate, presence: true, numericality: true

  scope :entry_point, -> { where(is_entry_point: true) }
  scope :non_entry_point, -> { where.not(is_entry_point: true) }

  def to_s
    name
  end
end
