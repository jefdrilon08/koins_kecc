class CreateJournalEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :journal_entries, id: :uuid do |t|
      t.string :post_type
      t.references :accounting_code, type: :uuid, foreign_key: true
      t.references :accounting_entry, type: :uuid, foreign_key: true
      t.json :data
      t.decimal :amount

      t.timestamps
    end
  end
end
