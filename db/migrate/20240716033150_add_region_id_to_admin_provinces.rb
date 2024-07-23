class AddRegionIdToAdminProvinces < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_provinces, :region_id, :uuid
    # add_foreign_key :admin_provinces, :admin_regions, column: :region_id, type: :uiid
  end
end
