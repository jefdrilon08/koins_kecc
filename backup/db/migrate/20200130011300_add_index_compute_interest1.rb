class AddIndexComputeInterest1 < ActiveRecord::Migration[5.2]
  def change
    # CREATE INDEX compute_interest1 ON account_transactions (subsidiary_id, transacted_at) WHERE transaction_type IN ('deposit', 'withdrawal') AND NOT (data->>'is_interest' = 'true');
    add_index(
      :account_transactions,
      [:subsidiary_id, :transacted_at],
      name: 'idx_compute_interest1',
      where: "transaction_type IN ('deposit', 'withdraw') AND NOT (data->>'is_interest' = 'true')"
    )
  end
end
