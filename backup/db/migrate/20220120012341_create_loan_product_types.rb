class CreateLoanProductTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_product_types, id: :uuid do |t|
      t.string :name
      t.references :loan_product, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
