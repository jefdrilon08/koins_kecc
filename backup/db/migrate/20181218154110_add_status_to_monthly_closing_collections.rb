class AddStatusToMonthlyClosingCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :monthly_closing_collections, :status, :string
  end
end
