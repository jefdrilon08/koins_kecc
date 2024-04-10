class CreateLoanProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :loan_products, id: :uuid do |t|
      t.string :name
      t.decimal :max_loan_amount
      t.decimal :min_loan_amount
      t.decimal :denomination
      t.boolean :insured
      t.boolean :is_entry_point
      t.decimal :monthly_interest_rate

      t.timestamps
    end
  end
end
