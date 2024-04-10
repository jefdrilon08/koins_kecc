class AddAmountForClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :claims, :amount, :decimal
  end
end
