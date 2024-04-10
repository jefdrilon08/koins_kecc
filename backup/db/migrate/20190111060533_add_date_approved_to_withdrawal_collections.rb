class AddDateApprovedToWithdrawalCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :withdrawal_collections, :date_approved, :date
  end
end
