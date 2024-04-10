class AddStatusToDataStores < ActiveRecord::Migration[5.2]
  def change
    add_column :data_stores, :status, :string
  end
end
