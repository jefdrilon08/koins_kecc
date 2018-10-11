class AccountTransaction < ApplicationRecord
  belongs_to :subsidiary, polymorphic: true

  scope :savings, -> { where(transaction_type: ["deposit", "withdraw"]).order("transacted_at ASC") }
  scope :savings_deposits, -> { where(transaction_type: "deposit").order("transacted_at ASC") }
  scope :approved_loan_payments, -> { where(transaction_type: "loan_payment").order("transacted_at ASC") }

  def deposit?
    self.transaction_type == "deposit"
  end

  def withdraw?
    self.transaction_type == "withdraw"
  end
end
