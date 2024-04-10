class ChangeEquityValueInterestToInterest < ActiveRecord::Migration[6.1]
  def change
  	rename_table :equity_value_interests, :interests
  end
end
