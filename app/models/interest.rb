class Interest < ApplicationRecord
  belongs_to :account_transaction
  belongs_to :member_account

  validates :interest_amount, presence: true, numericality: true

  def equity_value_interest
	self.interest_type == "ev_interest"
  end

  def rf_interest
  	self.interest_type == "rf_interest"
  end
end
