class CreateMakePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :make_payments, id: :uuid do |t|
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :transaction_date
      t.date :date_approve
      t.string :approved_by
      t.string :created_by
      t.json :data
      t.string :status

      t.timestamps
    end
  end
end
