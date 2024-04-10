class CreateSavingsInsuranceTransferCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :savings_insurance_transfer_collections, id: :uuid do |t|
      t.string :status
      t.references :center, foreign_key: true, type: :uuid
      t.references :branch, foreign_key: true, type: :uuid
      t.date :collection_date
      t.date :date_approved
      t.jsonb :data

      t.timestamps
    end
  end
end
