class AddIsActiveToAdminAddress < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_addresses, :is_active, :boolean
  end
end
