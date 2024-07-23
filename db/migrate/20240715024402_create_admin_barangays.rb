class CreateAdminBarangays < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_barangays, id: :uuid do |t|
      t.string :barangay_name
      t.json :data

      t.timestamps
    end
  end
end
