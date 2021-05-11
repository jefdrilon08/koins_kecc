class Interest < ApplicationRecord
  belongs_to :account_transaction
  belongs_to :member_account

  validates :interest_amount, presence: true, numericality: true

  def equity_value_interest
	self.type == "equity_value_interest"
  end

  def rf_interest
  	self.type == "retirement_fund_interest"
  end
end
