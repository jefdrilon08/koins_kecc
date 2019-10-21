class AddTransactionTypeIndexToAccountTransactions < ActiveRecord::Migration[5.2]
  def change
    add_index :account_transactions, :transaction_type
  end
end
