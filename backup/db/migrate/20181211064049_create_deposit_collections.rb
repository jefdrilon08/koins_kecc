class CreateDepositCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
  end
end
