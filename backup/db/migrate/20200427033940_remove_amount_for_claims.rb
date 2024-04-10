class RemoveAmountForClaims < ActiveRecord::Migration[5.2]
  def change
  	remove_column :claims, :amount, :decimal
  end
end
