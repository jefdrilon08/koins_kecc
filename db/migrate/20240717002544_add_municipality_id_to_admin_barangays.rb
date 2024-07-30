class AddMunicipalityIdToAdminBarangays < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_barangays, :municipality_id, :uuid
  end
end
