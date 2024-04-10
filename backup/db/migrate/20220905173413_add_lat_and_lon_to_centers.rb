class AddLatAndLonToCenters < ActiveRecord::Migration[7.0]
  def change
    add_column :centers, :lat, :decimal
    add_column :centers, :lon, :decimal
  end
end
