class EquityValueInterest < ApplicationRecord
  belongs_to :account_transaction
  belongs_to :member_account

  validates :interest_amount, presence: true, numericality: true
end
