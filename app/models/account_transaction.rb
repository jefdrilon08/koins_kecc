class AccountTransaction < ApplicationRecord
  belongs_to :subsidiary, polymorphic: true

  scope :personal_funds, -> { where(transaction_type: ["deposit", "withdraw"]) }
  scope :personal_funds_deposits, -> { where(transaction_type: "deposit") }
  scope :personal_funds_withdrawals, -> { where(transaction_type: "withdraw") }
  scope :savings, -> { where(transaction_type: ["deposit", "withdraw"]).order("transacted_at ASC, updated_at ASC") }
  scope :savings_deposits, -> { where(transaction_type: "deposit").order("transacted_at ASC, updated_at ASC") }
  scope :savings_withdrawals, -> { where(transaction_type: "withdraw").order("transacted_at ASC, updated_at ASC") }
  scope :approved_loan_payments, -> { where("transaction_type = ? AND amount > 0", "loan_payment").order("transacted_at ASC") }
  scope :approved, -> { where(status: "approved") }
  scope :interest, -> { where("transaction_type = ? AND CAST(data->>'is_interest' AS boolean) = ?", "deposit", 't') }

  scope :approved_member_account_transactions, -> (subsidiary_id, as_of, types = ["deposit", "withdraw"]) { where("subsidiary_id = ? AND status = ? AND transaction_type IN (?) AND transacted_at <= ?", subsidiary_id, "approved", types, as_of).order("transacted_at ASC") }

  validates :amount, presence: true, numericality: true

  def deposit?
    self.transaction_type == "deposit"
  end

  def withdraw?
    self.transaction_type == "withdraw"
  end

  def interest?
    self.transaction_type == "deposit" and self.data.with_indifferent_access[:is_interest] == true
  end
end
