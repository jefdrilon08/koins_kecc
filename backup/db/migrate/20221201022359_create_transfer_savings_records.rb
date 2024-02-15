class CreateTransferSavingsRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :transfer_savings_records, id: :uuid do |t|
      t.references :branch , foreign_key: true,type: :uuid
      t.references :center , foreign_key: true,type: :uuid
      t.date       :date_approved
      t.string     :status
      t.jsonb      :data
      t.timestamps
    end
  end
end
