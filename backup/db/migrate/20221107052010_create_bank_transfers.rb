class CreateBankTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transfers, id: :uuid do |t|
      t.string :name
      t.decimal :amount
      t.jsonb :data
      t.uuid :accounting_entry_id
      t.references :transfer_option, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
