class CreateCommissionCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :commission_collections, id: :uuid do |t|
      t.date :start_date
      t.date :end_date
      t.date :date_approved
      t.date :date_prepared
      t.jsonb :data
      t.jsonb :meta
      t.string :status
      t.string :category

      t.timestamps
    end
  end
end
