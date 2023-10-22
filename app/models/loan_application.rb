class LoanApplication < ApplicationRecord
  STATUSES = [
    "pending",
    "processing",
    "approved"
  ]

  belongs_to :loan_product
  belongs_to :loan_product_type
  belongs_to :member

  validates :amount, presence: true, numericality: true
  validates :term, presence: true
  validates :num_installments, presence: true
  validates :status, presence: true
  validates :reference_number, presence: true, uniqueness: true
  validates :date_applied, presence: true
end
