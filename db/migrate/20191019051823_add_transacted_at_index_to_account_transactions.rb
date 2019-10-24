class AddTransactedAtIndexToAccountTransactions < ActiveRecord::Migration[5.2]
  def change
    add_index :account_transactions, :transacted_at
  end
end
