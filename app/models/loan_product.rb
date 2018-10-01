class LoanProduct < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :max_loan_amount, presence: true, numericality: true
  validates :min_loan_amount, presence: true, numericality: true
  validates :monthly_interest_rate, presence: true, numericality: true
end
