class CreateMonthlyClosingCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_closing_collections, id: :uuid do |t|
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta

      t.timestamps
    end
  end
end
