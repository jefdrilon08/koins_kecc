class AddProvinceNameToAdminAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_addresses, :province_name, :string
  end
end
