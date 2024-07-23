class CreateAdminProvinces < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_provinces, id: :uuid do |t|
      t.string :province_name
      t.json :data

      t.timestamps
    end
  end
end
