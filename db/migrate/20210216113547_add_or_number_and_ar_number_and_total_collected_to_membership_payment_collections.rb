class AddOrNumberAndArNumberAndTotalCollectedToMembershipPaymentCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :membership_payment_collections, :or_number, :string
    add_column :membership_payment_collections, :ar_number, :string
    add_column :membership_payment_collections, :total_collected, :decimal
  end
end
