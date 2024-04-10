class CreateLoans < ActiveRecord::Migration[5.2]
  def change
    create_table :loans, id: :uuid do |t|
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.date :date_prepared
      t.date :date_approved
      t.date :date_released
      t.date :date_completed
      t.references :member, type: :uuid, foreign_key: true
      t.decimal :principal
      t.decimal :interest
      t.decimal :principal_paid
      t.decimal :principal_balance
      t.decimal :interest_paid
      t.decimal :interest_balance
      t.string :status
      t.references :loan_product, type: :uuid, foreign_key: true
      t.string :term
      t.string :pn_number
      t.string :payment_type
      t.integer :num_installments
      t.decimal :monthly_interest_rate
      t.references :project_type, type: :uuid, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
