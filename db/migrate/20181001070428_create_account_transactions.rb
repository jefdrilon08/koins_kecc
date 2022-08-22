class CreateAccountTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :account_transactions, id: :uuid do |t|
      t.uuid :subsidiary_id
      t.string :subsidiary_type
      t.decimal :amount
      t.string :transaction_type
      t.datetime :transacted_at
      t.string :status
      t.json :data

      t.timestamps
    end
  end
end
