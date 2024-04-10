class CreateDataStores < ActiveRecord::Migration[5.2]
  def change
    create_table :data_stores, id: :uuid do |t|
      t.json :meta
      t.json :data

      t.timestamps
    end
  end
end
