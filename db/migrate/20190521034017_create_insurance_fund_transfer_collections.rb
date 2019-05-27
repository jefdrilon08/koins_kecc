class CreateInsuranceFundTransferCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :insurance_fund_transfer_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status
      t.date :date_approved
      
      t.timestamps
    end
  end
end
