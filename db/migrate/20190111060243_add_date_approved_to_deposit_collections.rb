class AddDateApprovedToDepositCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :deposit_collections, :date_approved, :date
  end
end
