class AccountTransaction < ApplicationRecord
  belongs_to :subsidiary, polymorphic: true

  scope :savings, -> { where(transaction_type: ["deposit", "withdraw"]).order("transacted_at ASC") }
  scope :savings_deposits, -> { where(transaction_type: "deposit").order("transacted_at ASC") }
  scope :approved_loan_payments, -> { where("transaction_type = ? AND amount > 0", "loan_payment").order("transacted_at ASC") }
  scope :approved, -> { where(status: "approved") }

  validates :amount, presence: true, numericality: true

  def deposit?
    self.transaction_type == "deposit"
  end

  def withdraw?
    self.transaction_type == "withdraw"
  end
end
