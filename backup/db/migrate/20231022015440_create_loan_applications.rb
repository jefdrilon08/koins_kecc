class CreateLoanApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :loan_applications, id: :uuid do |t|
      t.references :loan_product, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, null: false
      t.string :term, null: false
      t.integer :num_installments, null: false
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status, null: false
      t.date :date_applied, null: false
      t.string :reference_number, null: false

      t.timestamps
    end
  end
end
