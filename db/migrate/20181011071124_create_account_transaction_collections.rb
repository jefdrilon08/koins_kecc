class CreateAccountTransactionCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :account_transaction_collections, id: :uuid do |t|
      t.string :or_number
      t.decimal :total_amount
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :status
      t.datetime :transacted_at
      t.string :collection_type
      t.json :data

      t.timestamps
    end
  end
end
