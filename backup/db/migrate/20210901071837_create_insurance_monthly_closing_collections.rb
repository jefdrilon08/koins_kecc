class CreateInsuranceMonthlyClosingCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :insurance_monthly_closing_collections, id: :uuid do |t|
      t.references :branch, type: :uuid, foreign_key: true
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta
      t.string :status
      t.string :account_subtype

      t.timestamps
    end
  end
end
