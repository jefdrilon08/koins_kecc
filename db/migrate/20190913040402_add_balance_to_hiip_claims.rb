class AddBalanceToHiipClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :hiip_claims, :balance, :decimal
  end
end
