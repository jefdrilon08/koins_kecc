class CreateAdministrationAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :administration_addresses, id: :uuid do |t|
      t.string :region_name
      t.json :data

      t.timestamps
    end
  end
end
