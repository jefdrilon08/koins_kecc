class AddCategoryAndDateRegisteredToReferrers < ActiveRecord::Migration[6.1]
  def change
    add_column :referrers, :date_registered, :date
    add_column :referrers, :category, :string
  end
end
