class AccountTransaction < ApplicationRecord
  belongs_to :subsidiary, polymorphic: true

  scope :personal_funds, -> { where(transaction_type: ["deposit", "withdraw"]) }
  scope :personal_funds_deposits, -> { where(transaction_type: "deposit") }
  scope :personal_funds_withdrawals, -> { where(transaction_type: "withdraw") }
  scope :savings, -> { where(transaction_type: ["deposit", "withdraw"]).order("transacted_at ASC, updated_at ASC") }
  scope :savings_deposits, -> { where(transaction_type: "deposit").order("transacted_at ASC, updated_at ASC") }
  scope :savings_withdrawals, -> { where(transaction_type: "withdraw").order("transacted_at ASC, updated_at ASC") }
  scope :approved_loan_payments, -> { where("transaction_type = ? AND amount > 0 AND status = ?", "loan_payment", "approved").order("transacted_at ASC") }
  scope :accrued_interest_payments, -> { where("transaction_type = ? AND amount > 0 AND status = ?", "deposit", "approved").order("transacted_at ASC") }
  scope :approved, -> { where(status: "approved") }
  scope :interest, -> { where("transaction_type = ? AND CAST(data->>'is_interest' AS boolean) = ?", "deposit", 't') }

  scope :approved_member_account_transactions, -> (subsidiary_id, as_of, types = ["deposit", "withdraw"]) { where("subsidiary_id = ? AND status = ? AND transaction_type IN (?) AND transacted_at <= ?", subsidiary_id, "approved", types, as_of).order("transacted_at ASC") }

  has_many :interests, dependent: :delete_all

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

  def withdraw_ev?
    self.transaction_type == "withdraw" and self.data.with_indifferent_access[:is_withdraw_ev] == true
  end

  def to_v2_hash
    data = self.data.with_indifferent_access

    {
      id: self.id,
      subsidiary_id: self.subsidiary_id,
      subsidiary_type: "MemberAccount",
      amount: self.amount,
      transaction_type: self.transaction_type,
      transacted_at: self.transacted_at,
      status: self.status,
      data: {
        is_withdraw_payment: data[:is_withdraw_payment],
        is_fund_transfer: data[:is_fund_transfer],
        is_interest: data[:is_interest],
        is_adjustment: data[:is_adjustment],
        is_for_exit_age: data[:is_for_exit_age],
        is_for_loan_payments: data[:is_for_loan_payments],
        accounting_entry_reference_number: data[:accounting_entry_reference_number],
        accounting_entry_particular: data[:accounting_entry_particular],
        beginning_balance: data[:beginning_balance],
        ending_balance: data[:ending_balance]
      }
    }
  end
end
