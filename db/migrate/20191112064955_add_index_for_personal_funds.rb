class AddIndexForPersonalFunds < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :account_transactions, 
      [:subsidiary_id, :transaction_type, :transacted_at], 
      name: 'idx_account_transactions_soa_personal_funds', 
      where: "(amount > 0)"
    )
  end
end
