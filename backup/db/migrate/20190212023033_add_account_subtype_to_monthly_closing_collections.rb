class AddAccountSubtypeToMonthlyClosingCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :monthly_closing_collections, :account_subtype, :string
  end
end
