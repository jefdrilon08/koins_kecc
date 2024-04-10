class AddExternalRefToAccountTransactions < ActiveRecord::Migration[7.0]
  def change
     add_column :account_transactions, :external_ref, :uuid
  end
end
