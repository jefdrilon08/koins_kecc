class CreateAccountingEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_entries, id: :uuid do |t|
      t.date :date_prepared
      t.date :date_posted
      t.references :branch, type: :uuid, foreign_key: true
      t.string :book
      t.string :reference_number
      t.string :particular
      t.string :approved_by
      t.string :prepared_by
      t.string :status
      t.json :data

      t.timestamps
    end
  end
end
