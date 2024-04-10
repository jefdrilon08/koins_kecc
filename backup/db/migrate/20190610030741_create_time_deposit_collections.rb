class CreateTimeDepositCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :time_deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, foreign_key: true, type: :uuid
      t.references :branch, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
  end
end
