class AddTotalCollectedAndTotalExpectedCollectionsToBillings < ActiveRecord::Migration[6.1]
  def change
    add_column :billings, :total_collected, :decimal
    add_column :billings, :total_expected_collections, :decimal
  end
end
