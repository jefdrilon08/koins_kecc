class AddProvinceIdToAdminMunicipalities < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_municipalities, :province_id, :uuid
  end
end
