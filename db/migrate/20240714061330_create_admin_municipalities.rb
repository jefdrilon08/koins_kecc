class CreateAdminMunicipalities < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_municipalities, id: :uuid do |t|
      t.string :municipality_name
      t.json :data

      t.timestamps
    end
  end
end
