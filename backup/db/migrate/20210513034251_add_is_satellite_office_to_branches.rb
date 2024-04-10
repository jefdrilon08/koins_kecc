class AddIsSatelliteOfficeToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :is_main, :boolean
  end
end
